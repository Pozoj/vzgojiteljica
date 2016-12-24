# frozen_string_literal: true
class AddPublishedToInquiries < ActiveRecord::Migration
  def change
    add_column :inquiries, :published, :boolean, default: false
    add_index :inquiries, :published
  end
end
