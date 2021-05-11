ActiveAdmin.register_page "Settings" do
  permit_params :longitude, :latitude, :zoom

  index do
    selectable_column
    id_column
    column :longitude
    column :latitude
    column :zoom
    actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :longitude
      f.input :latitude
      f.input :zoom
    end
    f.actions
  end
end
