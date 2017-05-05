class Account < ActiveRecord::Base
  belongs_to :bank
  belongs_to :user
  has_many :transactions, :dependent => :destroy

  include ModelHelpers::CredentialsHelper

  def newest_transaction_id
    transactions.pluck(:transaction_id).
      sort_by { |str| str =~ /([0-9]+)$/ && $1.to_i }.last
  end

  def figo_credentials=(val)
    self.creds = self.creds.merge("figo_creds" => val)
  end

  def iban_valid?
    IBANTools::IBAN.valid?(iban)
  end

  def iban_obj
    IBANTools::IBAN.new(iban)
  end

  def cluster_transactions_by_month(filter = :all)
    {}.tap do |hsh|
      transactions.select do |trans|
        case filter.to_s
        when "atm"      then trans.atm?
        when "rent"     then trans.rent?
        when "electric" then trans.electric?
        else true
        end
      end.group_by do |transaction|
        transaction.booking_date.strftime("%Y%m")
      end.each do |month, transactions|
        all_transactions = transactions.to_a
        hsh[month] = {
          "debit"  => all_transactions.select(&:debit?),
          "credit" => all_transactions.select(&:credit?),
          "all"    => all_transactions
        }
      end
    end
  end
end
