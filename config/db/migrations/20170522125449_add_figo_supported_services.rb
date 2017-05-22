class AddFigoSupportedServices < ActiveRecord::Migration
  def change
    create_table :figo_supported_services do |t|
      t.string :name
      t.string :bank_code, :index => true
      t.text :advice
      t.text :details_json
    end
  end
end
