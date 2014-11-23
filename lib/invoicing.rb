module Invoicing
  TAX_PERCENT = 9.5

  protected

  def tax_multiplier
    (tax_percent / 100) + 1
  end
end