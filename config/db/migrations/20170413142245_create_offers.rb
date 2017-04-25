class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :email
      t.string :amount

      t.string :classname

      t.belongs_to :entity, :index => true
      t.belongs_to :investment, :index => true

      t.timestamps
    end
  end
end
