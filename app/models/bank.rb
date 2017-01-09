# frozen_string_literal: true
class Bank < ActiveRecord::Base
  EINVOICE_BIC = 'BSLJSI2X'

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

  def einvoice?
    bic == EINVOICE_BIC
  end

  def self.einvoice_bank
    find_by(bic: EINVOICE_BIC)
  end
end
