# frozen_string_literal: true
class AddIndexForLineItems < ActiveRecord::Migration
  def change
    add_index :line_items, :invoice_id
  end
end
