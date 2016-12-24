# frozen_string_literal: true
class Remark < ActiveRecord::Base
  belongs_to :remarkable, polymorphic: true
  belongs_to :user
end
