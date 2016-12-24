# frozen_string_literal: true
class Plan < ActiveRecord::Base
  include Invoicing

  monetize :price_cents

  has_many :subscriptions
  belongs_to :batch

  def free?
    price == 0.0
  end

  def price_with_tax
    price * tax_multiplier
  end

  def to_s
    name
  end

  def yearly?
    billing_frequency == 1
  end

  def self.latest(frequency)
    Plan.where(billing_frequency: frequency).where('price_cents > 0').order(created_at: :desc).first
  end

  def self.free
    Plan.where(price_cents: 0).last
  end

  def self.latest_yearly
    Plan.latest 1
  end

  def self.latest_per_issue
    Plan.latest 6
  end
end
