class Transaction < ActiveRecord::Base
  belongs_to :account

  self.inheritance_column = :classname

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
end

class FigoTransaction < Transaction
end

class Mt940Transaction < Transaction
end
