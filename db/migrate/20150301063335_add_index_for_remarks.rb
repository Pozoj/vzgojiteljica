class AddIndexForRemarks < ActiveRecord::Migration
  def change
    add_index :remarks, :user_id
    add_index :remarks, :remarkable_id
    add_index :remarks, :remarkable_type
  end
end
