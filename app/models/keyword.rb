# frozen_string_literal: true
class Keyword < ActiveRecord::Base
  has_many :keywordables
  has_many :articles, through: :keywordables

  default_scope { order(:keyword) }

  validates_presence_of :keyword
  validates_uniqueness_of :keyword

  def to_s
    keyword
  end
end
