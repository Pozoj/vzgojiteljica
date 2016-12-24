# frozen_string_literal: true
class Section < ActiveRecord::Base
  has_many :articles
  default_scope { order('position, name') }

  def to_s
    name
  end
end
