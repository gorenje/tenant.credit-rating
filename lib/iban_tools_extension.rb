require 'iban-tools'

module IBANTools
  class IBAN
    def valid?
      validation_errors.empty?
    end
  end
end
