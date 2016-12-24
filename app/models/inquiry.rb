# frozen_string_literal: true
class Inquiry < ActiveRecord::Base
  attr_accessor :helmet
  validates_presence_of :subject, :question
  validates :email, email: true, presence: true, if: proc { |inquiry| !inquiry.created_at || (inquiry.created_at > Time.parse('2015-08-24 03:44:08 +0000')) }

  scope :published, -> { where(published: true) }

  def to_s
    subject
  end
end
