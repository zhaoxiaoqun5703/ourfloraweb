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
      row :picture_file_name
      row :picture_content_type
      row :picture_file_size
      row :picture_updated_at
      row :thumbnail do
        image_tag(pic.image.url(:thumb))
      end
      # Will display the image on show object page
    end
  end
end
