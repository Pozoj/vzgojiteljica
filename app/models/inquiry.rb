class Inquiry < ActiveRecord::Base
  attr_accessor :helmet
  validates_presence_of :subject, :question
  validates :email, email: true

  scope :published, -> { where(published: true) }
  
  def to_s
    subject
  end
end
