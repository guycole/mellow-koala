class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.string :uuid, null: false
      t.string :host, null: false
      t.datetime :start_time, null: false
      t.datetime :stop_time

      t.timestamps
    end
    add_index :tasks, :uuid, unique: true
    add_index :tasks, :name
    add_index :tasks, :start_time
  end
end
