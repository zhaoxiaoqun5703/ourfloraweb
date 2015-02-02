class Trail < ActiveRecord::Base
  has_many :species_trails
  has_many :species, through: :species_trails, :class_name => 'Species'

  accepts_nested_attributes_for :species_trails, :allow_destroy => true
end
