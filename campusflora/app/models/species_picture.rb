class SpeciesPicture < ActiveRecord::Base
  belongs_to :species
  belongs_to :pictures
end
