class CreateTrees < ActiveRecord::Migration
  def change
    create_table :trees do |t|
      t.string :name, limit: 50

      t.timestamps
    end
  end
end
