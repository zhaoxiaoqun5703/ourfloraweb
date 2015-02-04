class Image < ActiveRecord::Base
  belongs_to :species
  before_save :update_genus_species

  # Add a paperclip interpolation for species name
  Paperclip.interpolates :genusSpecies do |attachment, style|
    attachment.instance.genusSpecies
  end

  has_attached_file :image,
                    :styles => { :medium => "300x300>",
                    :thumb => "100x100>",
                    :tiny => "50x50#" },
                    :default_url => "/images/:style/missing.png",
                    :path => ":rails_root/public/assets/species_images/:genusSpecies/:id/:style_:basename.:extension",
                    :url  => "/assets/species_images/:genusSpecies/:id/:style_:basename.:extension"

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def update_genus_species
    self.genusSpecies = self.species.genusSpecies
  end
end