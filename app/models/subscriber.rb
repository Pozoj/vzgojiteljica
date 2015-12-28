class Subscriber < Entity
  belongs_to :customer
  has_many :subscriptions, dependent: :destroy
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id

  scope :active, -> { joins(:subscriptions).merge(Subscription.active) }
  scope :inactive, -> { joins(:subscriptions).merge(Subscription.inactive) }
  scope :paid,   -> { joins(:subscriptions).merge(Subscription.paid) }
  scope :free,   -> { joins(:subscriptions).merge(Subscription.free) }
end
