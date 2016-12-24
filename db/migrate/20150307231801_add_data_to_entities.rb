# frozen_string_literal: true
class AddDataToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :bank_id, :integer
    add_column :entities, :registration_number, :integer

    add_index :entities, :bank_id
    add_index :entities, :registration_number, unique: true
  end
end
