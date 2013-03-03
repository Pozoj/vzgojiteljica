class Author < ActiveRecord::Base
  has_many :articles
  belongs_to :institution
end
