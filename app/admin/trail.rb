ActiveAdmin.register Trail do
  permit_params :name, :slug, species_trails_attributes: [:species_id, :trail_id, :id, :_destroy]
  remove_filter :species_trails

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

    f.inputs 'Species' do
      f.has_many :species_trails, heading: "Species", allow_destroy: true, new_record: true do |a|
        a.input :species_id, :label => 'Genus Species', :as => :select, :collection => Species.all.order(:genusSpecies).map{|s| ["#{s.genusSpecies}", s.id]}
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
    end

    panel 'Species' do
      table_for trail.species do
        column 'ID', :id
        column 'Genus Species', :genusSpecies
        column 'Common Name', :commonName
      end
    end

    active_admin_comments_for(resource)
  end
end
