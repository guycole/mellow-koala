class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :stop_time
      t.string :host

      t.timestamps
    end
  end
end
