class Keyword < ActiveRecord::Base
  has_many :keywordables
  has_many :articles, through: :keywordables

  validates_presence_of :keyword
  validates_uniqueness_of :keyword
end
