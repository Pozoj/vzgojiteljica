class ChangeSomeTimeFieldsToDates < ActiveRecord::Migration
  def change
    change_column :order_forms, :issued_at, :date
  end
end
