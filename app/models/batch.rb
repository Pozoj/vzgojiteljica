class Batch < ActiveRecord::Base
  has_many :plans
  has_many :issues
end
