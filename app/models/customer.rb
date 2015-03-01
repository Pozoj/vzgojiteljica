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
end
