class Transaction < ActiveRecord::Base
  belongs_to :account

  self.inheritance_column = :classname
end

class FigoTransaction < Transaction
end

class Mt940Transaction < Transaction
end
