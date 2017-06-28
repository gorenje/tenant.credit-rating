class FigoSupportedBank < ActiveRecord::Base
  def self.get_bank(iban)
    if IBANTools::IBAN.valid?(iban.code)
      return nil if iban.country_code != 'DE'
      get_bank_by_blz(iban.to_local[:blz])
    else
      get_bank_by_blz(iban.code) || get_bank_by_bic(iban.code)
    end
  end

  def self.get_bank_by_iban(iban)
    return nil unless IBANTools::IBAN.valid?(iban.code)
    return nil if iban.country_code != 'DE'

    FigoSupportedBank.where(:bank_code => iban.to_local[:blz]).first
  end

  def self.get_bank_by_bic(bic)
    FigoSupportedBank.where(:bic => bic).first
  end

  def self.get_bank_by_blz(blz)
    FigoSupportedBank.where(:bank_code => blz).first
  end

  def credentials
    JSON(details_json)["credentials"]
  end

  def icon
    JSON(details_json)["icon"]
  end
end
