ActiveAdmin.register Trail do
  permit_params :name, :slug, :information, species_location_trails_attributes: [:id, :species_location_id, :trail_id, :_destroy]
  remove_filter :species_location_trails

  controller do
    def find_resource
      scoped_collection.where(slug: params[:id]).first!
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs 'Details' do
      f.inputs          # builds an input field for every attribute
    end

    f.inputs 'Individual Plants' do
      f.has_many :species_location_trails, heading: "Individual Plants", allow_destroy: true, new_record: true do |a|
        a.input :species_location_id, :label => 'Plant (Species Location) ID', :as => :select, :collection => SpeciesLocation.all.order(:arborplan_id).map{|s| ["ID: #{s.id} - Arborplan ID: #{s.arborplan_id} - #{s.species.genusSpecies}", s.id]}
      end
    end

    # f.inputs 'Select Species' do
    #   f.input :species, :collection => Species.pluck(:genusSpecies, :id)
    # end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  show do |trail|
    attributes_table do
      row :name
      row :slug
      row :information
    end

    panel 'Individual Plants' do
      table_for trail.species_locations do
        column 'ID', :id
        column 'Arborplan ID', :arborplan_id
        column 'Latitude', :lat
        column 'Longitude', :lon
      end
    end

    active_admin_comments_for(resource)
  end
end
