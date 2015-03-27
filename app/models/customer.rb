class Customer < Entity
  has_many :subscriptions, through: :subscribers
  has_many :subscribers, dependent: :destroy
  has_many :invoices
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id

  def quantity
    subscriptions.active.inject(0) { |sum, s| sum += s.quantity }
  end

  def self.active_count
    Subscription.active.group_by { |subscription| subscription.try(:subscriber).try(:customer_id) }.count
  end

  def self.paid_count
    Subscription.active.paid.group_by { |subscription| subscription.subscriber.customer_id }.count
  end

  def self.new_from_order(order_id)
    order = Order.find(order_id)

    customer = self.new
    customer.title = order.title
    customer.name = order.name
    customer.address = order.address
    customer.post_id = order.post_id
    customer.phone = order.phone
    customer.email = order.email
    customer.vat_id = order.vat_id.gsub(/[^0-9]/, '')
    return customer unless customer.save

    customer.remarks.create remark: "Naročnik ustvarjen avtomatsko iz naročila ##{order.id} na spletni strani."

    subscriber = customer.subscribers.new
    subscriber.title = order.title
    subscriber.name = order.name
    subscriber.address = order.address
    subscriber.post_id = order.post_id
    return subscriber unless subscriber.save

    if order.comments.present?
      subscriber.remarks.create remark: "Opomba naročnika: \"#{order.comments}\""
    end

    subscription = subscriber.subscriptions.new
    subscription.start = Date.today
    subscription.quantity = order.quantity
    if order.plan_type
      subscription.plan = Plan.latest(order.plan_type)
    end
    return subscription unless subscription.save

    order.processed = true
    order.save!
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
end
