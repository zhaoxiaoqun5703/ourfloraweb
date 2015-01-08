class Species < ActiveRecord::Base
  belongs_to :family
  has_many :species_locations
  has_and_belongs_to_many :trails
  has_many :species_pictures
  has_many :pictures, through: :species_pictures

  accepts_nested_attributes_for :family
  accepts_nested_attributes_for :species_locations
  accepts_nested_attributes_for :pictures
end
