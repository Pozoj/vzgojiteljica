class Subscription < ActiveRecord::Base
  include Invoicing

  attr_accessor :free_type

  belongs_to :plan
  belongs_to :subscriber
  belongs_to :order_form
  belongs_to :order # TODO: remove after migration
  has_many :remarks, as: :remarkable, dependent: :destroy

  scope :active, -> { where(arel_table[:start].lteq(Date.today).and(arel_table[:end].eq(nil).or(arel_table[:end].gteq(Date.today)))) }
  scope :inactive, -> { where(arel_table[:end].not_eq(nil).and(arel_table[:end].lteq(Date.today).or(arel_table[:start].gteq(Date.today)))) }
  scope :yearly, -> { joins(:plan).where(plans: {billing_frequency: 1}) }
  scope :per_issue, -> { joins(:plan).where.not(plans: {billing_frequency: 1}) }
  scope :paid, -> { joins(:plan).where.not(plans: {price_cents: 0}) }
  scope :free, -> { joins(:plan).where(plans: {price_cents: 0}) }

  validates_presence_of :quantity
  validates_presence_of :plan
  validates_presence_of :subscriber
  validates_numericality_of :quantity, greater_than: 0, only_integer: true
  validate :validate_end_after_start

  def customer
    subscriber.customer
  end

  def product issue = nil
    if plan.yearly?
      "Vzgojiteljica #{Time.now.year} - Letna naročnina"
    else
      "Vzgojiteljica #{issue}"
    end
  end

  def price_without_discount
    plan.price
  end

  def price
    return price_without_discount unless discount
    (1 - (discount/100)) * price_without_discount
  end

  def active?
    (self.start <= Date.today) && (!self.end.present? || self.end >= Date.today)
  end

  def inactive?
    !active?
  end

  def to_s
    "#{plan} za #{subscriber}"
  end

  def self.new_from_order(subscriber, order)
    Subscription.transaction do
      subscription = subscriber.subscriptions.new
      subscription.start = Date.today
      subscription.quantity = order.quantity
      subscription.order_form = order.order_form
      if order.comments.present?
        subscription.remarks.create remark: "Opomba naročnika: \"#{order.comments}\""
      end
      if order.plan_type
        subscription.plan = Plan.latest(order.plan_type)
      end

      raise FromOrderError("Can't save subscription") unless subscription.save

      subscription
    end
  end

  private

  def validate_end_after_start
    if self.end.present? && self.end <= self.start
      errors.add :end, "mora biti kasneje od pričetka"
    end
  end

  class FromOrderError < StandardError; end
end
