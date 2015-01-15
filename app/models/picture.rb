class Picture < ActiveRecord::Base
  has_many :species_pictures
  has_many :species, through: :species_pictures
  has_attached_file :picture,
                    :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :default_url => "/images/:style/missing.png",
                    :path => ":rails_root/app/assets/images/species_images/:id/:style_:basename.:extension",
                    :url => "/assets/images/species_images/:id/:style_:basename.:extension"
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/

  def picture_url
    picture.url(:original)
  end
end
