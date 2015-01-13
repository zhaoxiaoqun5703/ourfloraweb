class Trail < ActiveRecord::Base
  has_many :species_trails
  has_many :species, through: :species_trails

  accepts_nested_attributes_for :species_trails
end
