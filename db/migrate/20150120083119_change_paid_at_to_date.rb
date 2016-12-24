# frozen_string_literal: true
class ChangePaidAtToDate < ActiveRecord::Migration
  def change
    change_column :invoices, :paid_at, :date
  end
end
