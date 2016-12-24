# frozen_string_literal: true
class AddIndexCustomerIdOnEntities < ActiveRecord::Migration
  def change
    add_index :entities, :customer_id
  end
end
