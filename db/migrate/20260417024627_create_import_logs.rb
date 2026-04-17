class CreateImportLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :import_logs do |t|
      t.string :source_file, null: false
      t.string :import_type, null: false
      t.datetime :run_at, null: false
      t.integer :records_processed, null: false, default: 0
      t.integer :records_inserted, null: false, default: 0
      t.integer :records_skipped, null: false, default: 0
      t.text :error_details

      t.timestamps
    end
    add_index :import_logs, :import_type
    add_index :import_logs, :run_at
  end
end
