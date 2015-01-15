ActiveAdmin.register Trail do
  permit_params :name, species_ids: []
  remove_filter :species_trails

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs 'Details' do
      f.inputs          # builds an input field for every attribute
    end

    f.inputs 'Select Species' do
      f.input :species, :collection => Species.pluck(:genusSpecies, :id)
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  show do |trail|
    attributes_table do
      row :name
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
