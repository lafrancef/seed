class AddTraceToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :type, :string # STI
	add_column :nodes, :trace_id, :integer # For a node: which trace it is linked to
	add_column :nodes, :trace_idx, :string, limit: 3 # For a trace: its trace index (j, k, etc.)
  end
end
