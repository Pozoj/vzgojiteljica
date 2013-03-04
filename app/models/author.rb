class Author < ActiveRecord::Base
  has_many :authorships
  has_many :articles, through: :authorships
  belongs_to :institution
  belongs_to :post

  validates_presence_of :last_name

  def to_s
    "#{first_name} #{last_name}"
  end
end
