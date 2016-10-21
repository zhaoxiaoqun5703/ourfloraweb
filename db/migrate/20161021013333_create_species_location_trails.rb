class CreateSpeciesLocationTrails < ActiveRecord::Migration
  def change
    create_table :species_location_trails do |t|
      t.belongs_to :species_location, index: true
      t.belongs_to :trail, index: true
      t.timestamps null: false
    end
  end
end
