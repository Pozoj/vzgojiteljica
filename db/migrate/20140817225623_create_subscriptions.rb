class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :subscriber_id
      t.date :start
      t.date :end
      t.integer :discount
      t.integer :plan_id

      t.timestamps
    end

    add_index :subscriptions, :plan_id
  end
end
