class CreatePageContent < ActiveRecord::Migration
  def change
    create_table :page_contents do |t|
      t.text :about_page_content
      t.timestamps null: false
    end
  end
end
