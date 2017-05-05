# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170505092352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "accounts", force: :cascade do |t|
    t.string   "figo_account_id"
    t.string   "owner"
    t.string   "name"
    t.string   "account_number"
    t.string   "currency"
    t.string   "iban"
    t.string   "account_type"
    t.text     "icon_url"
    t.decimal  "last_known_balance"
    t.string   "sepa_creditor_id"
    t.boolean  "save_pin"
    t.text     "credentials"
    t.integer  "user_id"
    t.integer  "bank_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "accounts", ["user_id", "figo_account_id"], name: "index_accounts_on_user_id_and_figo_account_id", using: :btree

  create_table "banks", force: :cascade do |t|
    t.string   "figo_bank_id"
    t.string   "figo_bank_code"
    t.string   "figo_bank_name"
    t.string   "iban_bank_code"
    t.string   "iban_bank_name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "banks", ["figo_bank_id"], name: "index_banks_on_figo_bank_id", using: :btree
  add_index "banks", ["iban_bank_code"], name: "index_banks_on_iban_bank_code", using: :btree

  create_table "rating_histories", force: :cascade do |t|
    t.integer  "score"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "score"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string   "transaction_id"
    t.string   "name"
    t.decimal  "amount"
    t.string   "currency"
    t.date     "booking_date"
    t.date     "value_date"
    t.boolean  "booked"
    t.text     "booking_text"
    t.text     "purpose"
    t.text     "transaction_type"
    t.hstore   "extras"
    t.string   "classname"
    t.integer  "account_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "transactions", ["account_id", "transaction_id"], name: "index_transactions_on_account_id_and_transaction_id", using: :btree
  add_index "transactions", ["transaction_id"], name: "index_transactions_on_transaction_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "name"
    t.hstore   "address"
    t.boolean  "email_verified"
    t.string   "language"
    t.datetime "join_date"
    t.text     "credentials"
    t.string   "salt"
    t.string   "confirm_token"
    t.boolean  "has_confirmed",              default: false
    t.hstore   "last_import_attempt_status"
    t.datetime "last_successful_import"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["last_successful_import"], name: "index_users_on_last_successful_import", using: :btree

end
