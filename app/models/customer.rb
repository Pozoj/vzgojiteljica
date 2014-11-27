class Customer < Entity
  has_many :subscriptions, through: :subscribers, dependent: :destroy
  has_many :subscribers, dependent: :destroy
  has_many :invoices
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id

  def quantity
    subscriptions.active.inject(0) { |sum, s| sum += s.quantity }
  end
end
