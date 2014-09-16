class Post < ActiveRecord::Base
  has_many :orders
  default_scope { order(:name) }

  self.primary_key = 'id'

  def to_s
    "#{id} #{name}"
  end
end
