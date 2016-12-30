# frozen_string_literal: true
class Subscriber < Entity
  belongs_to :customer
  has_many :subscriptions, dependent: :destroy
  has_one :contact_person, foreign_key: :entity_id
  has_one :billing_person, foreign_key: :entity_id
  has_one :author, foreign_key: :entity_id

  scope :active, -> { joins(:subscriptions).merge(Subscription.active).group('entities.id') }
  scope :paid,   -> { joins(:subscriptions).merge(Subscription.paid).group('entities.id') }
  scope :free,   -> { joins(:subscriptions).merge(Subscription.free).group('entities.id') }

  def global_remarks
    tbl = Remark.arel_table
    query = tbl[:remarkable_id].eq(id).and(tbl[:remarkable_type].eq('Entity'))
    query = query.or(tbl[:remarkable_id].in(subscription_ids).and(tbl[:remarkable_type].eq('Subscription')))
    Remark.where(query)
  end

  def self.inactive
    Subscriber.all - Subscriber.active
  end

  def active?
    subscriptions.active.any?
  end

  def inactive?
    !active?
  end
end
