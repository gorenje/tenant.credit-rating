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
