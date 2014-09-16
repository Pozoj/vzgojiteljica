class Plan < ActiveRecord::Base
  has_many :subscriptions
  belongs_to :batch

  def free?
    price == 0.0
  end

  def to_s
    name
  end
end
