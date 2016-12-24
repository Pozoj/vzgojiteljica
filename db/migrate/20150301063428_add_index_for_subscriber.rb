# frozen_string_literal: true
class AddIndexForSubscriber < ActiveRecord::Migration
  def change
    add_index :subscriptions, :subscriber_id
    add_index :subscriptions, :start
    add_index :subscriptions, :end
  end
end
