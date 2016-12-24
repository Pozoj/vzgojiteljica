# frozen_string_literal: true
class AddAccountNumberToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :account_number, :string
    add_index :entities, :account_number
  end
end
