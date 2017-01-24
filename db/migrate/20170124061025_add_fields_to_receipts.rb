class AddFieldsToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :period_from, :date
    add_column :receipts, :period_to, :date

    Receipt.all.each do |receipt|
      receipt.period_from = receipt.created_at.to_datetime.beginning_of_day
      receipt.period_to = receipt.created_at.to_datetime.beginning_of_day
      receipt.save
    end
  end
end
