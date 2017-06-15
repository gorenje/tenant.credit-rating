class AddDeatilsToBonitaetHistory < ActiveRecord::Migration
  def change
    add_column :rating_histories, :details, :hstore
    add_column :ratings, :details, :hstore
  end
end
