class AddMarkersToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :case, :boolean
    add_column :nodes, :theta, :boolean
  end
end
