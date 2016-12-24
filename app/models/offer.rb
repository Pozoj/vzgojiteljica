# frozen_string_literal: true
class Offer < Receipt
  has_one :order_form

  def to_s
    "Ponudba #{receipt_id} "
  end
end
