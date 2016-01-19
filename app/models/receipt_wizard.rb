class ReceiptWizard
  include ActiveModel::Model

  ISSUES_PER_YEAR = 6

  attr_accessor :issue_id,
                :last_receipt_number,
                :due_at_date,
                :include_yearly,
                :type

  def model
    raise TypeMissingError unless type

    if type.to_sym == :invoice
      return Invoice
    elsif type.to_sym == :offer
      return Offer
    end
  end

  def reference_number
    return last_receipt_number.to_i if last_receipt_number.present?

    last = model.order(:year, :reference_number).last
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

  def build_line_item_for_subscription(subscription)
    line_item = LineItem.new

    # Assign issue_id if we're not talking about a yearly subscription.
    if issue_id && !subscription.plan.yearly?
      line_item.issue_id = issue_id
    end

    line_item.entity_name = subscription.subscriber.to_s
    line_item.product = subscription.product(line_item.issue)
    line_item.quantity = subscription.quantity
    line_item.unit = subscription.plan.quantity_unit_abbr
    line_item.price_per_item = subscription.price_without_discount
    line_item.discount_percent = subscription.discount
    line_item.price_per_item_with_discount = subscription.price

    return line_item
  end

  def build_receipt(options = {})
    unless options[:customer] || options[:subscription]
      raise ArgumentError
    end

    receipt = model.new
    receipt.skip_s3 = true
    receipt.reference_number = next_reference_number
    receipt.customer = options[:customer] || options[:subscription].customer

    if options[:subscription]
      receipt.order_form = options[:subscription].order_form
    end

    receipt.due_at = due_at

    return receipt
  end

  def build_receipt_for_subscription(subscription)
    receipt = build_receipt(subscription: subscription)

    raise SubscriptionMissingPlanError unless subscription.plan

    receipt.line_items << build_line_item_for_subscription(subscription)
    receipt.line_items.each(&:calculate)
    receipt.calculate_totals

    return receipt
  end

  def build_partial_receipt_for_subscription(subscription, issues_left)
    receipt = build_receipt(subscription: subscription)
    plan = Plan.latest_per_issue
    issues_left = Integer(issues_left)

    # 6 per year
    start_issue = ISSUES_PER_YEAR - issues_left

    issues_left.times do |x|
      line_item = receipt.line_items.new
      line_item.entity_name = subscription.subscriber.to_s
      line_item.product = "Revija Vzgojiteljica #{start_issue + x + 1}/#{Date.today.year}"
      line_item.price_per_item = plan.price
      line_item.price_per_item_with_discount = plan.price
      line_item.quantity = subscription.quantity
      line_item.unit = plan.quantity_unit_abbr
      line_item.calculate
    end

    return receipt
  end

  def create_receipt_for_subscription(subscription)
    Receipt.transaction do
      receipt = build_receipt_for_subscription(subscription)
      receipt.save!
    end
  end


  def create_receipt_for_customer(customer, subscriptions = nil)
    Customer.transaction do
      subscriptions ||= customer.subscriptions.paid.active
      return unless subscriptions.any?

      receipt = build_receipt(customer: customer)

      subscriptions.each do |s|
        next unless s.plan
        receipt.line_items << build_line_item_for_subscription(s)
      end

      receipt.line_items.each(&:calculate)
      receipt.calculate_totals

      # Sanity check
      if receipt.subtotal === 0.00
        raise "Invoice should not be 0."
      end

      # Save.
      receipt.save!

      return receipt
    end
  end

  def create_receipts(only: nil)
    receipts = []

    Customer.transaction do
      receipts = Customer.all.map do |customer|
        subscriptions = customer.subscriptions.paid.active

        if only == :yearly
          subscriptions = subscriptions.yearly
        elsif only == :per_issue
          subscriptions = subscriptions.per_issue
        end

        next unless subscriptions.any?

        create_receipt_for_customer(customer, subscriptions)
      end
    end

    return receipts
  end

  def create_yearly_receipts
    create_receipts(only: :yearly)
  end

  def create_per_issue_receipts
    create_receipts(only: :per_issue)
  end

  class TypeMissingError < StandardError; end
end
