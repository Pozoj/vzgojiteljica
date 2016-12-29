class AddFieldsToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :num_pages, :integer, default: 28
  end
end
