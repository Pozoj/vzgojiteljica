class AddBatchIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :batch_id, :integer
    add_index :issues, :batch_id
  end
end
