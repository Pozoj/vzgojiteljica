class Order < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :quantity, :greater_than => 0
end
