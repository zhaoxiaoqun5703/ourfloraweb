ActiveAdmin.register Species do
  permit_params :commonName, :authority, :distribution, :indigenousName, :information, :genusSpecies, :description, :family_id, species_locations_attributes: [:lat, :lon, :id, :_destroy], species_pictures_attributes: [:picture, :id]
  config.filters.each {|name,value| remove_filter(name) if name.match /#{config.resource_table_name.gsub('"','')}_*/ }
  
  form :html => { :enctype => "multipart/form-data" } do |f|
    binding.pry
    f.semantic_errors # shows errors on :base
    f.inputs          # builds an input field for every attribute
    f.inputs do
      f.has_many :species_locations, heading: 'Locations', allow_destroy: true, new_record: true do |a|
        a.input :lat
        a.input :lon  
      end
      f.has_many :picture, heading: 'Pictures', allow_destroy: true, new_record: true do |a|
        a.input :picture, :as => :file
      end
    end
    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
