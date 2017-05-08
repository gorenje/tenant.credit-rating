class Transaction < ActiveRecord::Base
  belongs_to :account

  self.inheritance_column = :classname

  class << self
    def filter(filter = :nil)
      select do |trans|
        case filter.to_s
        when "atm"      then trans.atm?
        when "rent"     then trans.rent?
        when "electric" then trans.electric?
        else true
        end
      end
    end
  end

  def credit?
    amount.to_f >= 0
  end

  def debit?
    amount.to_f < 0
  end

  def atm?
    name =~ /^GA/
  end

  def rent?
    purpose =~ /miete/i
  end

  def electric?
    purpose =~ /strom/i
  end

  def to_f
    amount.to_f
  end
end

class FigoTransaction < Transaction
end

class Mt940Transaction < Transaction
end
