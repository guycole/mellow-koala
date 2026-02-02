class AddUuidToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :uuid, :string, null: false, default: ""
    add_index :tasks, :uuid, unique: true
  end
end
