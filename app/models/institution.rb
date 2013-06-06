class Institution < ActiveRecord::Base
  default_scope order(:name)
  has_many :authors

  def to_s
    name
  end
end
