# frozen_string_literal: true
class AddQuantityUnitToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :quantity_unit, :string
    add_column :plans, :quantity_unit_abbr, :string

    p = Plan.latest_yearly
    p.quantity_unit = 'naročnin(a)'
    p.quantity_unit_abbr = 'nar'
    p.save

    p = Plan.latest_per_issue
    p.quantity_unit = 'komad(ov)'
    p.quantity_unit_abbr = 'kom'
    p.save
  end
end
