# frozen_string_literal: true
class CreateOrderForms < ActiveRecord::Migration
  def change
    create_table :order_forms do |t|
      t.integer :customer_id
      t.string :form_id, null: false
      t.string :authorizer
      t.datetime :issued_at
      t.datetime :processed_at
      t.integer :order_id
      t.integer :offer_id
      t.integer :year
      t.attachment :document

      t.timestamps null: false
    end

    add_index :order_forms, :customer_id
    add_index :order_forms, :form_id
    add_index :order_forms, :order_id
    add_index :order_forms, :year

    add_column :subscriptions, :order_form_id, :integer
    add_index :subscriptions, :order_form_id

    # Migrate all orders.
    Order.all.each do |order|
      Order.transaction do
        order.send(:create_order_form)
        order_form = order.order_form

        order.subscriptions.each do |subscription|
          order_form.customer = subscription.customer
          order_form.save!
          order_form.subscriptions << subscription
          subscription.order_form_id = order_form.id
          subscription.save!
        end
      end
    end

    # Migrate all the rest subscriptions.
    Subscription
      .where(order_id: nil)
      .where('order_form IS NOT NULL AND order_form != \'\'')
      .each do |subscription|
      order_form = subscription.build_order_form
      order_form.form_id = subscription[:order_form]
      order_form.customer = subscription.customer
      order_form.save!
      order_form.subscriptions << subscription
      subscription.save!
    end
  end
end
