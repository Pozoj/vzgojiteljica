# frozen_string_literal: true
class Article < ActiveRecord::Base
  has_many :authorships
  has_many :authors, through: :authorships

  has_many :keywords, through: :keywordables
  has_many :keywordables

  belongs_to :section
  belongs_to :issue
  belongs_to :institution

  def to_param
    "#{id}-#{title.parameterize}"
  end
end
