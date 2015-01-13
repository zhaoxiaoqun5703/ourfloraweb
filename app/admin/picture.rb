ActiveAdmin.register Picture do
  permit_params :picture
  config.filters.each {|name,value| remove_filter(name) if name.match /#{config.resource_table_name.gsub('"','')}_*/ }

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.semantic_errors
    f.inputs "Upload Image" do
      f.input :picture, :as => :file, :hint => f.template.image_tag(f.object.picture.url(:medium))
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
        image_tag(pic.picture.url(:thumb))
      end
      # Will display the image on show object page
    end
  end
end
