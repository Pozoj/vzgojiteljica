class AddAttachmentCoverDocumentToIssues < ActiveRecord::Migration
  def self.up
    change_table :issues do |t|
      t.attachment :cover
      t.attachment :document
    end
  end

  def self.down
    drop_attached_file :issues, :cover
    drop_attached_file :issues, :document
  end
end
