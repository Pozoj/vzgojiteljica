class Institution < ActiveRecord::Base
  has_many :authors

  def to_s
    name
  end
end
