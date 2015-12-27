class Customer < Entity
  has_many :subscriptions, through: :subscribers
  has_many :subscribers, dependent: :destroy
  has_many :invoices
  has_one :contact_person, foreign_key: :entity_id, dependent: :destroy
  has_one :billing_person, foreign_key: :entity_id, dependent: :destroy

  def quantity
    subscriptions.active.inject(0) { |sum, s| sum += s.quantity }
  end

  def billing_name
    if person?
      name
    else
      billing_person.try(:name)
    end
  end

  def merge_in(other_customer)
    return unless other_customer
    return if id == other_customer.id

    other_customer.subscribers.update_all(customer_id: id)
    other_customer.invoices.update_all(customer_id: id)
    other_customer.remarks.update_all(remarkable_id: id)
    other_customer.reload # Reload to not destroy cached relations, which now belong to other entities.
    other_customer.destroy
  end

  def billing_email
    if person?
      email
    else
      billing_person.try(:email)
    end
  end

  def self.active_count
    Subscription.active.group_by { |subscription| subscription.try(:subscriber).try(:customer_id) }.count
  end

  def self.paid_count
    Subscription.active.paid.group_by { |subscription| subscription.subscriber.customer_id }.count
  end

  def self.new_from_order(order)
    Customer.transaction do
      customer = self.new
      customer.title = order.title
      customer.name = order.name
      customer.address = order.address
      customer.post_id = order.post_id
      customer.phone = order.phone
      customer.email = order.email
      customer.vat_id = order.vat_id.gsub(/[^0-9]/, '')
      raise FromOrderError.new("Can't save customer: #{customer.errors.inspect}") unless customer.save

      customer.remarks.create remark: "Naročnik ustvarjen avtomatsko iz naročila ##{order.id} na spletni strani."

      subscriber = customer.subscribers.new
      subscriber.title = order.title
      subscriber.name = order.name
      subscriber.address = order.address
      subscriber.post_id = order.post_id
      raise FromOrderError.new("Can't save subscriber: #{subscriber.errors.inspect}") unless subscriber.save

      if order.comments.present?
        subscriber.remarks.create remark: "Opomba naročnika: \"#{order.comments}\""
      end

      subscription = subscriber.subscriptions.new
      subscription.start = Date.today
      subscription.quantity = order.quantity
      subscription.order = order
      subscription.order_form = "Naročilo ##{order.id}"
      if order.plan_type
        subscription.plan = Plan.latest(order.plan_type)
      end
      raise FromOrderError.new("Can't save subscription: #{subscription.errors.inspect}") unless subscription.save

      customer
    end
  end

  def halcom_export
    [
      to_s,
      address,
      post.to_s,
      'SLOVENIJA',
      '',
      account_number,
      bank.name,
      bank.address,
      bank.post.to_s,
      'SLOVENIJA',
      'SI',
      '',
      bank.bic,
      '',
      bank.account_number,
      0,
      '',
      vat_id_formatted.to_s,
      'SI'
    ].map do |el|
      if el.is_a?(String)
        '"' + el + '"'
      else
        el
      end
    end.join(',')
  end

  def to_s
    if title.present?
      title
    else
      name
    end
  end

  class FromOrderError < StandardError; end
end
