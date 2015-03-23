class LineItem < ActiveRecord::Base
  include Invoicing

  monetize :subtotal_cents
  monetize :total_cents
  monetize :price_per_item_cents
  monetize :price_per_item_with_discount_cents
  monetize :tax_cents

  belongs_to :invoice
  belongs_to :issue
  before_save :calculate

  def calculate
    self.tax_percent ||= TAX_PERCENT
    self.subtotal = price_per_item_with_discount * quantity
    self.total = subtotal * tax_multiplier
    self.tax = total - subtotal
  end

  def unit_eancom
    if unit == 'kom'
      'PCE'
    end
  end
end
