# frozen_string_literal: true
class AddTokenToCustomers < ActiveRecord::Migration
  def change
    add_column :entities, :token, :string
    add_index :entities, :token, unique: true

    Customer.all.each do |c|
      c.send(:generate_token)
      c.save
    end
  end
end
