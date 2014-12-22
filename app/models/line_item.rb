class LineItem < ActiveRecord::Base
  include Invoicing

  belongs_to :invoice
  belongs_to :issue
  before_save :calculate

  def calculate
    self.tax_percent ||= TAX_PERCENT
    self.subtotal = price_per_item_with_discount * quantity
    self.total = subtotal * tax_multiplier
    self.tax = total - subtotal
  end
end
