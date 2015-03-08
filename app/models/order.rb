class Order < ActiveRecord::Base
  attr_accessor :desire

  validates_presence_of :name
  validates :quantity, presence: true, numericality: {greater_than: 0, only_integer: true}
  validates :email, presence: true, email: true
  validates :plan_type, presence: true, inclusion: { in: [1, 6] }
  validate  :validate_plan_type

  belongs_to :post

  def order_id
    "#{created_at.strftime('%Y')}-#{id}"
  end

  def plan_type_string
    if plan_type == 1
      'Letna naročnina'
    elsif plan_type == 6
      'Plačilo za vsako posamezno številko'
    end
  end

  private

  def validate_plan_type
    return unless quantity? || plan_type?

    if quantity == 1 && plan_type == 6
      errors.add :plan_type, "za plačevanje po posamezni številki mora biti naročena količina vsaj 2"
    end
  end
end
