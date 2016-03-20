class Customer < Entity
  extend DuplicateFinder
  TOKEN_LENGTH = 6

  has_many :subscriptions, through: :subscribers
  has_many :subscribers, dependent: :destroy
  has_many :invoices
  has_many :offers
  has_many :order_forms
  has_one :contact_person, foreign_key: :entity_id, dependent: :destroy
  has_one :billing_person, foreign_key: :entity_id, dependent: :destroy

  before_validation :generate_token, on: :create

  scope :einvoiced, -> { where(einvoice: true) }
  scope :not_einvoiced, -> { where(einvoice: false) }

  validates :token, presence: true, length: {is: TOKEN_LENGTH}, uniqueness: true

  def global_remarks
    tbl = Remark.arel_table
    query = tbl[:remarkable_id].eq(id).and(tbl[:remarkable_type].eq('Entity'))
    query = query.or(tbl[:remarkable_id].in(subscriber_ids).and(tbl[:remarkable_type].eq('Entity')))
    query = query.or(tbl[:remarkable_id].in(subscriptions.map(&:id)).and(tbl[:remarkable_type].eq('Subscription')))
    query = query.or(tbl[:remarkable_id].in(invoice_ids).and(tbl[:remarkable_type].eq('Invoice')))
    Remark.where(query)
  end

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
    if billing_person && billing_person.email?
      return billing_person.try(:email)
    end

    email
  end

  def self.active
    Subscriber.select(:customer_id).
    joins(:subscriptions).
    merge(Subscription.active).
    includes(:customer).
    group(:customer_id).
    map(&:customer)
  end

  def self.active_and_paid
    Subscriber.select(:customer_id).
    joins(:subscriptions).
    merge(Subscription.active.paid).
    includes(:customer).
    group(:customer_id).
    map(&:customer)
  end

  def self.active_count
    Subscriber.select(:customer_id).
    joins(:subscriptions).
    merge(Subscription.active).
    group(:customer_id).
    to_a.count
  end

  def self.paid_count
    Subscriber.select(:customer_id).
    joins(:subscriptions).
    merge(Subscription.paid).merge(Subscription.active).
    group(:customer_id).
    to_a.count
  end

  def self.new_from_order(order:)
    Customer.transaction do
      customer = self.new
      customer.title = order.title
      customer.name = order.name
      customer.address = order.address
      customer.post_id = order.post_id
      customer.phone = order.phone
      customer.email = order.email
      if order.vat_id?
        customer.vat_id = order.vat_id.gsub(/[^0-9]/, '')
      end
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
      subscription.order_form = order.order_form
      if order.plan_type
        subscription.plan = Plan.latest(order.plan_type)
      end
      raise FromOrderError.new("Can't save subscription: #{subscription.errors.inspect}") unless subscription.save

      order.order_form.customer = customer
      order.order_form.save!

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
    elsif name.present?
      name
    else
      "Naročnik ##{id}"
    end
  end

  private

  def generate_token
    fund = ('A'..'Z').to_a

    self.token = ''
    TOKEN_LENGTH.times do
      self.token += fund[(SecureRandom.random_number(fund.length - 1))]
    end
  end

  class FromOrderError < StandardError; end
end
