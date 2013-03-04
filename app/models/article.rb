class Article < ActiveRecord::Base
  has_many :authorships
  has_many :authors, through: :authorships

  belongs_to :section
  belongs_to :issue
  belongs_to :institution
end
