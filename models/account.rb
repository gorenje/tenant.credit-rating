class Account < ActiveRecord::Base
  belongs_to :bank
  belongs_to :user
  has_many :transactions, :dependent => :destroy

  include ModelHelpers::CredentialsHelper

  class << self
    def in_credit
      where("last_known_balance > 0")
    end
  end

  def newest_transaction_id
    transactions.pluck(:transaction_id).
      sort_by { |str| str =~ /([0-9]+)$/ && $1.to_i }.last
  end

  def figo_credentials=(val)
    self.creds = self.creds.merge("figo_creds" => val)
  end

  def figo_credentials
    (self.creds || {})["figo_creds"]
  end

  def iban_valid?
    IBANTools::IBAN.valid?(iban)
  end

  def iban_obj
    IBANTools::IBAN.new(iban)
  end

  def update_from_figo_account(acc, dbbank)
    update(:owner              => acc.owner,
           :name               => acc.name,
           :account_type       => acc.type,
           :currency           => acc.currency,
           :iban               => acc.iban,
           :account_number     => acc.account_number,
           :icon_url           => acc.icon,
           :bank               => dbbank,
           :last_known_balance => acc.balance.balance.to_s,
           :save_pin           => acc.bank.save_pin,
           :sepa_creditor_id   => acc.bank.sepa_creditor_id)
  end

  def cluster_transactions_by_month(filter = :all)
    {}.tap do |hsh|
      transactions.filter(filter).
        group_by { |tran| tran.booking_date.strftime("%Y%m") }.
        each do |month, transactions|
        hsh[month] = {
          "debit"  => transactions.select(&:debit?),
          "credit" => transactions.select(&:credit?),
          "all"    => transactions
        }
      end
    end
  end
end
