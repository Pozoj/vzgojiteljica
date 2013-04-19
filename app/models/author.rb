class Author < ActiveRecord::Base
  has_many :authorships
  has_many :articles, through: :authorships
  belongs_to :institution
  belongs_to :post

  validates_presence_of :last_name

  def name
    "#{first_name} #{last_name}"
  end

  def to_s
    name
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
