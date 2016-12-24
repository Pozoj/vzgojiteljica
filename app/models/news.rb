# frozen_string_literal: true
class News < ActiveRecord::Base
  validates_presence_of :title
end
