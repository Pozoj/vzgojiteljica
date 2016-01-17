class AddNullConstraintOnReceiptsType < ActiveRecord::Migration
  def change
    change_column :receipts, :type, :string, null: false
  end
end
