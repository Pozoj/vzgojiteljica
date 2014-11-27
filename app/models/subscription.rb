class Subscription < ActiveRecord::Base
  include Invoicing
  
  belongs_to :plan
  belongs_to :subscriber
  has_many :remarks, as: :remarkable, dependent: :destroy

  scope :active, -> { where(arel_table[:start].lteq(Date.today).and(arel_table[:end].eq(nil).or(arel_table[:end].gteq(Date.today)))) }
  scope :inactive, -> { where(arel_table[:end].not_eq(nil).or(arel_table[:end].lteq(Date.today))) }

  validates_presence_of :quantity
  validates_numericality_of :quantity, greater_than: 0, only_integer: true

  def customer
    subscriber.customer
  end

  def active?
    (self.start <= Date.today) && (!self.end.present? || self.end >= Date.today)
  end

  def inactive?
    !active?
  end

  def to_s
    "#{plan} za #{subscriber}"
  end
end
