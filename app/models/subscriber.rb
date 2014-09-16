class Subscriber < Entity
  belongs_to :subscription
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id

  scope :active, -> { joins(:subscription).where(Subscription.arel_table[:end].eq(nil).or(Subscription.arel_table[:end].gteq(Date.today))) }
end
