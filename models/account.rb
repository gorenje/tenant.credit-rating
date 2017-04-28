class Account < ActiveRecord::Base
  belongs_to :bank
  belongs_to :user
  has_many :transactions

  include ModelHelpers::CredentialsHelper

  def newest_transaction_id
    transactions.pluck(:figo_transaction_id).
      sort_by { |str| str =~ /([0-9]+)$/ && $1.to_i }.last
  end

  def figo_credentials=(val)
    self.creds = self.creds.merge("figo_creds" => val)
  end

  def iban_valid?
    IBANTools::IBAN.valid?(iban)
  end
end
