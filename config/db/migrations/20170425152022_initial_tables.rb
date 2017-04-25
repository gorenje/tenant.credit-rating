class InitialTables < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :email, :index => true
      t.string   :name
      t.hstore   :address
      t.boolean  :email_verified
      t.string   :language
      t.datetime :join_date
      t.text     :access_token

      t.hstore :last_import_attempt_status
      t.datetime :last_successful_import, :index => true

      t.timestamps :null => false
    end

    create_table :accounts do |t|
      t.string  :figo_account_id
      t.string  :owner
      t.string  :name
      t.string  :account_number
      t.string  :currency
      t.string  :iban
      t.string  :account_type
      t.text    :icon_url
      t.decimal :last_known_balance

      t.belongs_to :user
      t.belongs_to :bank
      t.timestamps :null => false
    end

    add_index :accounts, [:user_id, :figo_account_id]

    create_table :banks do |t|
      t.string :figo_bank_id, :index => true
      t.string :figo_bank_code
      t.string :figo_bank_name
      t.string :sepa_creditor_id

      t.timestamps :null => false
    end

    create_table :transactions do |t|
      t.string   :figo_transaction_id, :index => true
      t.string   :name
      t.decimal  :amount
      t.string   :currency
      t.datetime :booking_date
      t.datetime :value_date
      t.boolean  :booked
      t.text     :booking_text
      t.text     :purpose
      t.text     :transaction_type

      t.belongs_to :account
      t.timestamps :null => false
    end

    add_index :transactions, [:account_id, :figo_transaction_id]
  end
end
