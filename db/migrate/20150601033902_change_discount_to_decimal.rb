# frozen_string_literal: true
class ChangeDiscountToDecimal < ActiveRecord::Migration
  def change
    change_column :subscriptions, :discount, :decimal, default: 0
  end
end
