class AddUnsubscribedAtToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :unsubscribed_at, :date
  end
end
