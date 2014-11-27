class AddQuantityToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :quantity, :integer

    Subscriber.all.each do |subscriber|
      subscriber.subscriptions.each do |subscription|
        subscription.quantity = subscriber.quantity
        subscription.save!
      end
    end
  end
end
