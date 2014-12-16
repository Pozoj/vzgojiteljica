class Subscriber < Entity
  belongs_to :customer
  has_many :subscriptions
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id

  scope :active, -> { joins(:subscriptions).merge(Subscription.active) }
end
