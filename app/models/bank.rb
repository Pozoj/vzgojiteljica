class Bank < ActiveRecord::Base
  has_many :entities

  belongs_to :post

  validates_presence_of :name
  validates :bic, presence: true, uniqueness: true

  def bic_elongated
    bic + ('X' * (11 - bic.length))
  end

  def to_s
    name
  end
end
