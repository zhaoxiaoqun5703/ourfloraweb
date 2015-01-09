ActiveAdmin.register Species do
  permit_params :commonName, :authority, :distribution, :indigenousName, :information, :genusSpecies, :description, :family_id, species_locations_attributes: [:lat, :lon, :id, :_destroy], pictures_attributes: [:picture, :id]
  config.filters.each {|name,value| remove_filter(name) if name.match /#{config.resource_table_name.gsub('"','')}_*/ }

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.semantic_errors # shows errors on :base
    f.inputs          # builds an input field for every attribute
    f.inputs do
      f.has_many :species_locations, heading: 'Locations', allow_destroy: true, new_record: true do |a|
        a.input :lat
        a.input :lon  
      end
      f.has_many :pictures, heading: 'Pictures', allow_destroy: true, new_record: true do |a|
        a.input :picture, :as => :file
      end
    end
    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  show do |species|
    attributes_table do
      row :family do
        species.family.name
      end
      row :genusSpecies
      row :commonName
      row :indigenousName
      row :authority
      row :distribution
      row :information
      row :description
    end

    panel 'Locations' do
      table_for species.species_locations do
        column 'Latitude', :lat
        column 'Longitude', :lon
      end
    end

    panel 'Images' do
      species.pictures.each do |pic|
        span do
          image_tag(pic.picture.url(:thumb))
        end
      end
    end
  end
end
