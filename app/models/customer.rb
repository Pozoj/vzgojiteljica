class Customer < Entity
  has_many :subscriptions
  has_many :subscribers, through: :subscriptions
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id
end
