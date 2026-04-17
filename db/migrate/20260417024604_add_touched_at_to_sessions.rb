class AddTouchedAtToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :touched_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" }
  end
end
