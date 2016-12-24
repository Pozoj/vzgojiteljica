# frozen_string_literal: true
class AddEntityTypeToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :entity_type, :integer
    add_index :entities, :entity_type
  end
end
