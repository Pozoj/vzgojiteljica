class Inquiry < ActiveRecord::Base
  validates_presence_of :subject, :question
  
  def to_s
    subject
  end
end
