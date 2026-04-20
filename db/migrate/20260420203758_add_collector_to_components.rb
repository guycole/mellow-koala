class AddCollectorToComponents < ActiveRecord::Migration[8.0]
  def change
    add_column :components, :collector, :boolean, null: false, default: false
  end
end
