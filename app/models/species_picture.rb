class SpeciesPicture < ActiveRecord::Base
  belongs_to :species
  belongs_to :picture
end
