class AddUidToTrees < ActiveRecord::Migration
  def change
    add_column :trees, :uid, :integer
  end
end
