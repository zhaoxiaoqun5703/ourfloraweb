class Trail < ActiveRecord::Base
  has_many :species_trails
  has_many :species, through: :species_trails, :class_name => 'Species'
  extend FriendlyId

  friendly_id :name, use: :slugged

  accepts_nested_attributes_for :species_trails, :allow_destroy => true

  def slug=(value)
    if value.present?
      write_attribute(:slug, value)
    end
  end
end