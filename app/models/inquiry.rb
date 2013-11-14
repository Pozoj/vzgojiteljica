class Inquiry < ActiveRecord::Base
  attr_accessor :helmet
  validates_presence_of :subject, :question
  
  def to_s
    subject
  end
end
