class AddPidToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :pid, :integer
  end
end
