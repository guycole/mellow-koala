class CreateCollectionSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :collection_snapshots do |t|
      t.references :component, null: false, foreign_key: true
      t.string :snapshot_id, null: false
      t.datetime :captured_at
      t.datetime :received_at, null: false
      t.string :status, null: false
      t.jsonb :payload, null: false
      t.jsonb :error_details

      t.timestamps
    end
    add_index :collection_snapshots, [ :component_id, :snapshot_id ], unique: true, name: 'idx_collection_snapshots_component_snapshot'
    add_index :collection_snapshots, [ :component_id, :received_at ]
  end
end
