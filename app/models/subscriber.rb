class Subscriber < Entity
  belongs_to :customer
  has_many :subscriptions, dependent: :destroy
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id

  scope :active, -> { joins(:subscriptions).merge(Subscription.active).group('entities.id') }
  scope :inactive, -> { joins(:subscriptions).merge(Subscription.inactive).group('entities.id') }
  scope :paid,   -> { joins(:subscriptions).merge(Subscription.paid).group('entities.id') }
  scope :free,   -> { joins(:subscriptions).merge(Subscription.free).group('entities.id') }
end
