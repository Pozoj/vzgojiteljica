module Invoicing
  TAX_PERCENT = 0

  protected

  def tax_multiplier
    tp = if defined? tax_percent
      tax_percent
    else
      TAX_PERCENT
    end
    
    (tp / 100) + 1
  end
end