class Trail < ActiveRecord::Base
  extend FriendlyId
  
  has_many :species_location_trails
  has_many :species_locations, through: :species_location_trails, :class_name => 'SpeciesLocation'

  friendly_id :name, use: :slugged

  accepts_nested_attributes_for :species_locations
  accepts_nested_attributes_for :species_location_trails, :allow_destroy => true

  def slug=(value)
    if value.present?
      write_attribute(:slug, value)
    end
  end
end