class AddFlagsToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :flags, :text
  end
end
