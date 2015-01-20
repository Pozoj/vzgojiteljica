class MonetizeAllTheThings < ActiveRecord::Migration
  def change
    # BATCHES
    rename_column :batches, :price, :price_decimal
    add_monetize :batches, :price
    Batch.all.each { |b| b.price = b.price_decimal; b.save }
    remove_column :batches, :price_decimal

    # INVOICES
    rename_column :invoices, :subtotal, :subtotal_decimal
    rename_column :invoices, :total, :total_decimal
    rename_column :invoices, :paid_amount, :paid_amount_decimal
    add_monetize :invoices, :subtotal
    add_monetize :invoices, :total
    add_monetize :invoices, :paid_amount
    Invoice.all.each { |b| b.subtotal = b.subtotal_decimal; b.save }
    Invoice.all.each { |b| b.total = b.total_decimal; b.save }
    Invoice.all.each { |b| b.paid_amount = b.paid_amount_decimal; b.save }
    remove_column :invoices, :subtotal_decimal
    remove_column :invoices, :total_decimal
    remove_column :invoices, :paid_amount_decimal

    # LINE ITEMS
    rename_column :line_items, :subtotal, :subtotal_decimal
    rename_column :line_items, :total, :total_decimal
    rename_column :line_items, :price_per_item, :price_per_item_decimal
    rename_column :line_items, :price_per_item_with_discount, :price_per_item_with_discount_decimal
    add_monetize :line_items, :subtotal
    add_monetize :line_items, :total
    add_monetize :line_items, :price_per_item
    add_monetize :line_items, :price_per_item_with_discount
    LineItem.all.each { |b| b.subtotal = b.subtotal_decimal; b.save }
    LineItem.all.each { |b| b.total = b.total_decimal; b.save }
    LineItem.all.each { |b| b.price_per_item = b.price_per_item_decimal; b.save }
    LineItem.all.each { |b| b.price_per_item_with_discount = b.price_per_item_with_discount_decimal; b.save }
    remove_column :line_items, :subtotal_decimal
    remove_column :line_items, :total_decimal
    remove_column :line_items, :price_per_item_decimal
    remove_column :line_items, :price_per_item_with_discount_decimal

    # PLANS
    rename_column :plans, :price, :price_decimal
    add_monetize :plans, :price
    Plan.all.each { |b| b.price = b.price_decimal; b.save }
    remove_column :plans, :price_decimal    
  end
end
