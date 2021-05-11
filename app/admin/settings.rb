ActiveAdmin.register_page "Settings" do
  permit_params :about_page_content
  actions :all, :except => [:destroy]

  # Prevent a new resource from being created, we can only edit this one row
  config.clear_action_items!

  show do |settings|
    # Initialize a markdown parser
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    attributes_table do
      row :about_page_content do
        markdown.render(settings.about_page_content).html_safe
      end
    end

    active_admin_comments_for(resource)
  end

    # This defines the column order for the index page which shows the list of all species
  index do
    column :about_page_content
    column :created_at
    column :updated_at
    actions
  end
  controller do
    def create
      @settings = Settings.create(permitted_params)
      do_some_magic_stuff_here
    end
  end
end
