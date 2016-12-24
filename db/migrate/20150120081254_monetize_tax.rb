# frozen_string_literal: true
class MonetizeTax < ActiveRecord::Migration
  def change
    rename_column :invoices, :tax, :tax_decimal
    add_monetize :invoices, :tax
    Invoice.all.each { |b| b.tax = b.tax_decimal; b.save }
    remove_column :invoices, :tax_decimal

    rename_column :line_items, :tax, :tax_decimal
    add_monetize :line_items, :tax
    LineItem.all.each { |b| b.tax = b.tax_decimal; b.save }
    remove_column :line_items, :tax_decimal
  end
end
