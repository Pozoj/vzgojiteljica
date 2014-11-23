class Customer < Entity
  has_many :subscriptions, through: :subscribers
  has_many :subscribers
  has_many :invoices
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id

  def quantity
    subscriptions.active.inject(0) { |sum, s| sum += s.subscriber.quantity }
  end 
end
