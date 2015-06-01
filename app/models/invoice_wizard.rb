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

  def create_invoice_for_subscription subscription
    i = build_invoice_for_subscription(subscription)
    i.save!
  end

  def create_invoices
    Customer.all.each do |c|
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

      i.save!
    end
  end

  def create_yearly_invoices
    Customer.all.each do |c|
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

      i.save!
    end
  end

  def create_per_issue_invoices
    Customer.all.each do |c|
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

      i.save!
    end
  end
end
