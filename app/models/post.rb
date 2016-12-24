# frozen_string_literal: true
class Post < ActiveRecord::Base
  has_many :orders
  belongs_to :master, class_name: 'Post'
  has_many :regional_children, class_name: 'Post', foreign_key: 'master_id'
  default_scope { order(:name) }

  self.primary_key = 'id'

  def to_s
    "#{id} #{name}"
  end

  def full_with_zip
    "#{name} (#{id})"
  end
end
