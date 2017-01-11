OrderForm.not_processed.where(year: 2017).each do |of|
  next if of.order # Skip web orders

  customer = of.customer
  puts "Processing #{of.id} #{of.form_id} #{customer}"

  Customer.transaction do
    customer.subscribers.each do |subscriber|
      subscriptions = subscriber.subscriptions.active.paid
      next unless subscriptions.any?

      one_subscription = subscriptions.first
      quantity = subscriptions.sum(:quantity)

      subscriptions.each do |subscription|
        subscription.end = Date.today
        subscription.remarks.create!(remark: "Naročnina je potekla, vnesli smo novo po naročilnici #{of.form_id}", user_id: User.first.id)
        unless subscription.valid?
          puts subscription.inspect
          puts subscription.errors.inspect
        end
        subscription.save!
      end

      new_subscription = one_subscription.dup
      new_subscription.quantity = quantity
      new_subscription.order_form = of
      new_subscription.start = Date.today
      new_subscription.end = nil
      unless new_subscription.valid?
        puts new_subscription.inspect
        puts new_subscription.errors.inspect
      end
      new_subscription.save!
      new_subscription.remarks.create!(remark: "Naročnina avtomatsko ustvarjena po oddani naročilnici #{of.form_id}", user_id: User.first.id)
    end
  end

  of.processed!(user_id: User.first.id)
end
