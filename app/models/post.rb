class Post < ActiveRecord::Base
  self.primary_key = 'id'

  def to_s
    "#{id} #{name}"
  end
end
