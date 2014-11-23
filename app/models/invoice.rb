class Invoice < ActiveRecord::Base
  include Invoicing

  belongs_to :customer
  belongs_to :issue
  has_many :remarks, as: :remarkable
  has_many :line_items, dependent: :destroy

  before_save :calculate_totals

  def reference_full
    "#{reference_number}/ REV /#{created_at.strftime("%Y")}"
  end

  def calculate_totals
    self.tax_percent = TAX_PERCENT
    self.tax = line_items.to_a.sum(&:tax)
    self.subtotal = line_items.to_a.sum(&:subtotal)
    self.total = line_items.to_a.sum(&:total)
  end
end
