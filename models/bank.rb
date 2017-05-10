class Bank < ActiveRecord::Base
  has_many :accounts

  def self.for_iban(iban)
    return nil if iban.country_code != 'DE'

    blz = iban.to_local[:blz]

    Bank.where(:iban_bank_code => blz).first ||
      Bank.create(:iban_bank_code => blz,
                  :iban_bank_name => BlzSearch.find_bank_name(iban))
  end

  def self.paypal
    Bank.where(:iban_bank_code => "paypal").first ||
      Bank.create(:iban_bank_code => "paypal",
                  :iban_bank_name => "Paypal")
  end

  def login_url
    BankLoginURLs[iban_bank_code]
  end
end
