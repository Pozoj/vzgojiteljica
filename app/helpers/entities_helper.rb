module EntitiesHelper
  def pluralize_days(days)
    case days
    when 0
      '0 dnevi'
    when 1
      '1 dnevom'
    when 2
      '2 dnevoma'
    else
      "#{days} dnevi"
    end
  end

  def pluralize_quantity(quantity)
    case quantity
    when 1
      '1 izvod'
    when 2
      '2 izvoda'
    when 3..4
      "#{quantity} izvode"
    else
      "#{quantity} izvodov"
    end
  end

  def pluralize_unpaid_invoices(invoices)
    case invoices
    when 1
      '1 neplačan račun'
    when 2
      '2 neplačana računa'
    when 3..4
      "#{invoices} neplačane račune"
    else
      "#{invoices} neplačanih računov"
    end
  end
end
