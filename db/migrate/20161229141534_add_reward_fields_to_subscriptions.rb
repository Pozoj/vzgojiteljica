class AddRewardFieldsToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :reward, :integer, default: 0
  end
end
