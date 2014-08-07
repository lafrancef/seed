class AddContentTriToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :show_content, :boolean
    add_column :nodes, :show_triangle, :boolean
  end
end
