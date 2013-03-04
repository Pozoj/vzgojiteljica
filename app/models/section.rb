class Section < ActiveRecord::Base
  has_many :articles

  def to_s
    name
  end
end
