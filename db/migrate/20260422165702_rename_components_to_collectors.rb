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

    # Note: PostgreSQL automatically renames indexes when tables/columns are
    # renamed, so explicit rename_index calls are not needed here.
  end
end
