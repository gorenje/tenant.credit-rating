class AddBicToFigoSupportedBank < ActiveRecord::Migration
  def change
    add_column :figo_supported_banks, :bic, :string
  end
end
