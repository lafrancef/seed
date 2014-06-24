class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.references :tree, index: true
      t.integer :relative_id
      t.string :part_of_speech, limit: 10
      t.string :contents, limit: 140

      t.timestamps
    end
  end
end
