Invoice.where('id >= 1772').each do |invoice|
  next if invoice.reference_number == 49 && invoice.year == 2015

  p invoice
  p invoice.line_items

  invoice.line_items.each do |li|
    if li.unit == 'kom'
      li.price_per_item = Plan.latest_per_issue.price
      li.price_per_item_with_discount = Plan.latest_per_issue.price
    elsif li.unit == 'nar'
      li.price_per_item = Plan.latest_yearly.price
      li.price_per_item_with_discount = Plan.latest_yearly.price
    end
    li.tax_percent = 0
    li.save
  end

  invoice.tax_percent = 0
  invoice.save

  p invoice
  p invoice.line_items
  puts
  puts
end;0
