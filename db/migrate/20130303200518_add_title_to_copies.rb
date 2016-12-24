# frozen_string_literal: true
class AddTitleToCopies < ActiveRecord::Migration
  def change
    add_column :copies, :title, :string
  end
end
