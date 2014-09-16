class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :customer
  has_many :subscribers
  has_many :remarks, as: :remarkable

  scope :active, -> { where(arel_table[:end].eq(nil).or(arel_table[:end].gteq(Date.today))) }
  scope :inactive, -> { where(arel_table[:end].not_eq(nil).or(arel_table[:end].lteq(Date.today))) }

  def quantity
    subscribers.sum(:quantity) or 0
  end

  def active?
    !self.end.present? || self.end >= Date.today
  end

  def inactive?
    !active?
  end
end
