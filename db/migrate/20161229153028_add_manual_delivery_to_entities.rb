class AddManualDeliveryToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :manual_delivery, :boolean, default: false
  end
end
