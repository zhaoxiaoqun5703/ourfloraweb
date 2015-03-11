ActiveAdmin.register Family do
  permit_params :name, :phylogeny

  # This defines the column order for the index page which shows the list of all families
  index do
    selectable_column
    column :name
    column :phylogeny
    column :created_at
    column :updated_at
    actions
  end
end
