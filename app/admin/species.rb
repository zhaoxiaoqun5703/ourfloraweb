ActiveAdmin.register Species do
  permit_params :commonName, :authority, :distribution, :indigenousName, :information, :genusSpecies, :description, :family_id, species_locations_attributes: [:lat, :lon, :id, :_destroy], images_attributes: [:image, :id, :_destroy]
  remove_filter :species_trails

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.semantic_errors # shows errors on :base
    f.inputs 'Details' do
      f.inputs          # builds an input field for every attribute
    end

    f.inputs 'Locations' do
      f.has_many :species_locations, heading: nil, allow_destroy: true, new_record: true do |a|
        a.input :lat
        a.input :lon  
      end
    end

    f.inputs 'images' do
      f.has_many :images, heading: nil, allow_destroy: true, new_record: true do |a|
        a.input :image, :as => :attachment,
                        :required => true,
                        :hint => 'Accepts JPG, GIF, PNG.',
                        :image => proc { |o| o.image.url(:thumb) }
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
        column 'Location ID', :id
        column 'Latitude', :lat
        column 'Longitude', :lon
      end
    end

    panel 'Images' do
      species.images.each do |pic|
        span do
          image_tag(pic.image.url(:thumb))
        end
      end
    end

    active_admin_comments_for(resource)
  end
end
