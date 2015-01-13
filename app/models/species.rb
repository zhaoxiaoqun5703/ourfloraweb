class Species < ActiveRecord::Base
  belongs_to :family
  has_many :species_locations

  has_many :species_trails
  has_many :trails, through: :species_trails, :class_name => 'Trail'

  has_many :species_pictures
  has_many :pictures, through: :species_pictures, :class_name => 'Picture'

  accepts_nested_attributes_for :family
  accepts_nested_attributes_for :species_locations
  accepts_nested_attributes_for :pictures

end
