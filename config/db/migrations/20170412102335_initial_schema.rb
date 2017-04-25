class InitialSchema < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :street_one
      t.string :street_two
      t.string :city
      t.string :country
      t.string :postcode

      t.string :email
      t.string :phone
      t.string :mobile

      t.hstore :data
      t.string :kind
    end

    add_index :locations, [:email, :phone]

    create_table :entities do |t|
      t.string :name
      t.string :description
      t.string :url
      t.string :image_url

      t.hstore :data

      t.string :classname

      t.belongs_to :location, :index => true
      t.timestamps :null => false
    end

    add_index :entities, :url

    create_table :keywords do |t|
      t.string :name
      t.string :description
    end

    create_table :keywords_startups do |t|
      t.belongs_to :keyword, :index => true
      t.belongs_to :startup, :index => true
    end

    create_table :investments do |t|
      t.decimal :valuation, {:precision=>10, :scale=>2}
      t.decimal :amount, {:precision=>10, :scale=>2}
      t.string :currency
      t.string :kind
      t.string :stake_percent
      t.date :when

      t.belongs_to :entity, :index => true
      t.belongs_to :startup, :index => true

      t.timestamps
    end

    create_table :key_employees do |t|
      t.string :role

      t.hstore :data

      t.belongs_to :entity, :index => true
      t.belongs_to :startup, :index => true

      t.timestamps
    end

    create_table :exit_strategies do |t|
      t.string :kind
      t.text :description
      t.belongs_to :startup
    end

    create_table :founding_structure do |t|
      t.string :kind
      t.text :description
    end

    create_table :startups do |t|
      t.string :name
      t.string :url
      t.string :logo_url

      t.date :founded
      t.date :exited

      t.text :description
      t.string :tagline
      t.string :industry
      t.string :sector

      t.hstore :data

      t.decimal :valuation_current, {:precision=>10, :scale=>2}
      t.decimal :success_chances

      t.belongs_to :founding_structure, :index => true
      t.belongs_to :location

      t.timestamps
    end

    add_index :startups, :url
  end
end
