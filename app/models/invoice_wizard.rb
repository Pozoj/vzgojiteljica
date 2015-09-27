class InvoiceWizard
  include ActiveModel::Model
  attr_accessor :issue_id, 
                :last_invoice_number,
                :due_at_date,
                :include_yearly

  def reference_number
    return last_invoice_number.to_i if last_invoice_number.present?
    last = Invoice.order(:year, :reference_number).last
    return last.reference_number if last
    0
  end

  def next_reference_number
    @reference_number ||= reference_number
    @reference_number += 1
  end

  def due_at
    return due_at_date if due_at_date
    30.days.from_now
  end

  def build_line_item_for_subscription subscription
    li = LineItem.new
    if issue_id && !subscription.plan.yearly?
      li.issue_id = issue_id
    end
    li.entity_name = subscription.subscriber.to_s
    li.product = subscription.product(li.issue)
    li.quantity = subscription.quantity
    li.unit = subscription.plan.quantity_unit_abbr
    li.price_per_item = subscription.price_without_discount
    li.discount_percent = subscription.discount
    li.price_per_item_with_discount = subscription.price
    li
  end

  def build_invoice options
    i = Invoice.new
    i.skip_s3 = true
    i.reference_number = next_reference_number
    i.customer = options[:customer] || options[:subscription].customer
    if options[:subscription]
      i.order_form = options[:subscription].order_form
    end
    i.due_at = due_at
    i
  end

  def build_invoice_for_subscription subscription
    i = build_invoice subscription: subscription
    
    unless subscription.plan
      puts subscription
      return
    end
    
    i.line_items << build_line_item_for_subscription(subscription)
    i.line_items.each(&:calculate)
    i.calculate_totals
    
    i
  end

  def build_partial_invoice_for_subscription(subscription, issues_left)
    i = build_invoice subscription: subscription
    plan = Plan.latest_per_issue
    issues_left = Integer(issues_left)

    # 6 per year
    start_issue = 6 - issues_left

    issues_left.times do |x|
      li = i.line_items.new
      li.entity_name = subscription.subscriber.to_s
      li.product = "Revija Vzgojiteljica #{start_issue + x + 1}/#{Date.today.year}"
      li.price_per_item = plan.price
      li.price_per_item_with_discount = plan.price
      li.quantity = subscription.quantity
      li.unit = plan.quantity_unit_abbr
      li.calculate
    end

    i
  end

  def create_invoice_for_subscription subscription
    i = build_invoice_for_subscription(subscription)
    i.save!
  end

  def create_invoices
    Customer.all.map do |c|
      subscriptions = c.subscriptions.paid.active
      next unless subscriptions.any?

      i = build_invoice customer: c
    
      subscriptions.each do |s|
        next unless s.plan
        i.line_items << build_line_item_for_subscription(s)
      end
      
      i.line_items.each(&:calculate)
      i.calculate_totals

      # Sanity check
      if i.subtotal === 0.00
        raise "Invoice should not be 0."
      end

      # Save.
      i.save!

      # Return invoice in array.
      i
    end
  end

  def create_yearly_invoices
    Customer.all.map do |c|
      subscriptions = c.subscriptions.yearly.paid.active
      next unless subscriptions.any?

      i = build_invoice customer: c
    
      subscriptions.each do |s|
        next unless s.plan
        i.line_items << build_line_item_for_subscription(s)
      end
      
      i.line_items.each(&:calculate)
      i.calculate_totals

      # Sanity check
      if i.subtotal === 0.00
        raise "Invoice should not be 0."
      end

      # Save.
      i.save!

      # Return invoice in array.
      i
    end
  end

  def create_per_issue_invoices
    Customer.all.map do |c|
      subscriptions = c.subscriptions.per_issue.paid.active
      next unless subscriptions.any?

      i = build_invoice customer: c
    
      subscriptions.each do |s|
        next unless s.plan
        i.line_items << build_line_item_for_subscription(s)
      end
      
      i.line_items.each(&:calculate)
      i.calculate_totals

      # Sanity check
      if i.subtotal === 0.00
        raise "Invoice should not be 0."
      end

      # Save.
      i.save!

      # Return invoice in array.
      i
    end
  end
end
