# frozen_string_literal: true
class AddUniqueIndexOnVatIdToEntities < ActiveRecord::Migration
  def change
    add_index :entities, :vat_id, unique: true
  end
end
