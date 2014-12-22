class AddIssueIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :issue_id, :integer
    LineItem.all.each do |li|
      li.issue_id = li.invoice.issue_id
      li.save
    end
    remove_column :invoices, :issue_id, :integer
  end
end
