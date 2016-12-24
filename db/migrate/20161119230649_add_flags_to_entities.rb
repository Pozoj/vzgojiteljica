# frozen_string_literal: true
class AddFlagsToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :flags, :text
  end
end
