class CreateBoxScores < ActiveRecord::Migration[8.0]
  def change
    create_table :box_scores do |t|
      t.string :task_name, null: false
      t.string :task_uuid, null: false
      t.string :uuid, null: false
      t.decimal :population, precision: 20, scale: 4, null: false
      t.datetime :time_stamp, null: false

      t.timestamps
    end
    add_index :box_scores, :uuid, unique: true
    add_index :box_scores, :task_uuid
    add_index :box_scores, :time_stamp
  end
end
