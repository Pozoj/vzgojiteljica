# frozen_string_literal: true
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :entity

  def to_s
    name || email
  end
end
