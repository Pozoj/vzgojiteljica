# frozen_string_literal: true
class Copy < ActiveRecord::Base
  def to_param
    page_code
  end
end
