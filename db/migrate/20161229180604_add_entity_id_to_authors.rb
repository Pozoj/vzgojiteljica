class AddEntityIdToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :entity_id, :integer
    add_index :authors, :entity_id
  end
end
