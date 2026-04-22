class CreateComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :components do |t|
      t.string :component_id, null: false
      t.string :display_name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :ingest_token_digest, null: false
      t.datetime :token_rotated_at

      t.timestamps
    end
    add_index :components, :component_id, unique: true
    add_index :components, :slug, unique: true
  end
end
