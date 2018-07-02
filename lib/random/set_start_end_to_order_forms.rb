OrderForm.where(year: 2018).reject { |of| of.start }.each do |of|
  next if of.order # Skip web order

  of.start = Date.today
  of.end = Date.today.end_of_year
  of.save
end
