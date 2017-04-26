class Account < ActiveRecord::Base
  belongs_to :bank
  belongs_to :user
  has_many :transactions

  def newest_transaction_id
    transactions.pluck(:figo_transaction_id).
      sort_by { |str| str =~ /([0-9]+)$/ && $1.to_i }.last
  end
end
