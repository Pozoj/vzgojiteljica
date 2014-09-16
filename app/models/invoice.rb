class Invoice < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :issue
  has_many :remarks, as: :remarkable

  before_save :calculate_missing

  def customer
    subscription.customer
  end

  def plan
    subscription.plan
  end

  def subtotal_for_subscriber(subscriber)
    subscriber.quantity * subscription.plan.price    
  end

  def tax_for_subscriber(subscriber)
    total_for_subscriber = subtotal_for_subscriber(subscriber) * tax_multiplier
    total_for_subscriber - subtotal_for_subscriber
  end

  def reference_full
    "#{reference_number}/ REV /#{created_at.strftime("%Y")}"
  end

  protected

  def tax_multiplier
    (tax_percent / 100) + 1
  end

  def calculate_missing
    self.tax_percent ||= 9.5 
    self.tax ||= if total
      self.subtotal ||= total / tax_multiplier
      total - subtotal
    elsif subtotal
      self.total ||= subtotal * tax_multiplier
      total - subtotal
    else
      raise "Missing total or subtotal"
    end
  end
end
