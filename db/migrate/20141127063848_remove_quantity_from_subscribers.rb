class RemoveQuantityFromSubscribers < ActiveRecord::Migration
  def change
    remove_column :entities, :quantity, :integer
  end
end
