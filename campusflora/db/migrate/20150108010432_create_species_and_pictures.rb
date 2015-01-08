class CreateSpeciesAndPictures < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :genusSpecies
      t.string :commonName
      t.string :indigenousName
      t.string :authority
      t.string :distribution
      t.string :information
      t.text :description

      t.timestamps null: false

      t.references :family
    end

    create_table :pictures do |t|
      t.timestamps null: false
    end

    create_table :species_pictures, id: false do |t|
      t.belongs_to :species, index: true
      t.belongs_to :picture, index: true
    end
  end
end
