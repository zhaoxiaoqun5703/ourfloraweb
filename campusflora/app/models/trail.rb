class Trail < ActiveRecord::Base
  has_and_belongs_to_many :species
end
