class Bank < ActiveRecord::Base
  has_many :entities
  validates_presence_of :name
  validates :bic, presence: true, length: {is: 11}
end
