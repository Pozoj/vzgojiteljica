class ChangeUniqueIndexOnReceipts < ActiveRecord::Migration
  def change
    remove_index :receipts, :receipt_id
    remove_index :receipts, :payment_id
    add_index :receipts, [:receipt_id, :type], unique: true
    add_index :receipts, [:payment_id, :type], unique: true
  end
end
