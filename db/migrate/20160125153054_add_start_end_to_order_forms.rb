# frozen_string_literal: true
class AddStartEndToOrderForms < ActiveRecord::Migration
  def change
    add_column :order_forms, :start, :date
    add_column :order_forms, :end, :date
  end
end
