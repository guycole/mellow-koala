class CreateBoxScores < ActiveRecord::Migration[7.0]
  def change
    create_table :box_scores do |t|
      t.string :task_name
      t.string :task_uuid
      t.integer :population
      t.datetime :time_stamp

      t.timestamps
    end
  end
end
