ActiveAdmin.register Image do
  permit_params :image

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.semantic_errors
    f.inputs "Upload Image" do
      f.input :image, :as => :file, :hint => f.template.image_tag(f.object.image.url(:medium))
      f.actions
    end
  end

  show do |pic|
    attributes_table do
      row :image_file_name
      row :image_content_type
      row :image_file_size
      row :image_updated_at
      row :thumbnail do
        image_tag(pic.image.url(:thumb))
      end
      # Will display the image on show object page
    end
  end
end
