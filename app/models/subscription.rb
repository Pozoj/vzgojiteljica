class Subscription < ActiveRecord::Base
  include Invoicing
  
  belongs_to :plan
  belongs_to :subscriber
  has_many :remarks, as: :remarkable

  scope :active, -> { where(arel_table[:end].eq(nil).or(arel_table[:end].gteq(Date.today))) }
  scope :inactive, -> { where(arel_table[:end].not_eq(nil).or(arel_table[:end].lteq(Date.today))) }

  def customer
    subscriber.customer
  end

  def quantity
    subscriber.quantity || 0
  end

  def active?
    !self.end.present? || self.end >= Date.today
  end

  def inactive?
    !active?
  end

  def to_s
    "#{plan} za #{subscriber}"
  end
end
