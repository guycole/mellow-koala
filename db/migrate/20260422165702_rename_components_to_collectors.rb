class RenameComponentsToCollectors < ActiveRecord::Migration[8.0]
  def change
    # 1. Remove foreign keys before structural changes
    remove_foreign_key :collection_snapshots, :components
    remove_foreign_key :configuration_snapshots, :components

    # 2. Rename FK columns in child tables (bigint collector references)
    rename_column :collection_snapshots,    :component_id, :collector_id
    rename_column :configuration_snapshots, :component_id, :collector_id

    # 3. Rename parent table
    rename_table :components, :collectors

    # 4. Rename string identifier column on parent
    rename_column :collectors, :component_id, :collector_id

    # 5. Rename the boolean flag
    rename_column :collectors, :collector, :collection_only

    # 6. Re-add foreign keys pointing at renamed table
    add_foreign_key :collection_snapshots,    :collectors
    add_foreign_key :configuration_snapshots, :collectors

    # 7. Rename indexes — parent table
    rename_index :collectors, :index_components_on_component_id, :index_collectors_on_collector_id
    rename_index :collectors, :index_components_on_slug,         :index_collectors_on_slug

    # 8. Rename indexes — collection_snapshots
    rename_index :collection_snapshots,
                 :index_collection_snapshots_on_component_id,
                 :index_collection_snapshots_on_collector_id
    rename_index :collection_snapshots,
                 :idx_collection_snapshots_component_snapshot,
                 :idx_collection_snapshots_collector_snapshot
    rename_index :collection_snapshots,
                 :index_collection_snapshots_on_component_id_and_received_at,
                 :index_collection_snapshots_on_collector_id_and_received_at

    # 9. Rename indexes — configuration_snapshots
    rename_index :configuration_snapshots,
                 :index_configuration_snapshots_on_component_id,
                 :index_configuration_snapshots_on_collector_id
    rename_index :configuration_snapshots,
                 :idx_config_snapshots_component_snapshot,
                 :idx_config_snapshots_collector_snapshot
    rename_index :configuration_snapshots,
                 :index_configuration_snapshots_on_component_id_and_received_at,
                 :index_configuration_snapshots_on_collector_id_and_received_at
  end
end
