class FixCase < ActiveRecord::Migration
  def change
	rename_column :nodes, :case, :case_marker
  end
end
