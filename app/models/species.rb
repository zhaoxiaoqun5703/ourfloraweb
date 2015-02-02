class Species < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  belongs_to :family
  has_many :species_locations

  has_many :species_trails
  has_many :trails, through: :species_trails, :class_name => 'Trail'

  has_many :images

  accepts_nested_attributes_for :family
  accepts_nested_attributes_for :species_locations, :allow_destroy => true
  accepts_nested_attributes_for :species_trails
  accepts_nested_attributes_for :images, :allow_destroy => true

  def html_link_description
    auto_link(self.description)
  end
end