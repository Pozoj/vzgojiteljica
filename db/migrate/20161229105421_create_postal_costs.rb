class CreatePostalCosts < ActiveRecord::Migration
  def change
    create_table :postal_costs do |t|
      t.column :weight_from, :integer
      t.column :weight_to, :integer
      t.column :price, :decimal, default: 0
      t.column :service_type, :string
    end

    add_index :postal_costs, :service_type
  end
end
