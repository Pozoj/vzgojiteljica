class Article < ActiveRecord::Base
  belongs_to :section
  belongs_to :author
  belongs_to :issue
  belongs_to :institution
end
