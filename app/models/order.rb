class Order < ActiveRecord::Base
  attr_accessor :desire

  validates_presence_of :name, :address, :post_id
  validates :quantity, presence: true, numericality: {greater_than: 0, only_integer: true}
  validates :email, presence: true, email: true
  validates :plan_type, presence: true, inclusion: { in: [1, 6] }
  validate  :validate_plan_type

  belongs_to :post
  has_many :subscriptions # TODO: remove after migration
  has_many :remarks, as: :remarkable, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  has_one :order_form

  scope :processed, -> { where(processed: true) }
  scope :not_processed, -> { where(processed: false) }

  after_create :create_order_form

  def order_id
    "#{created_at.strftime('%Y')}-#{id}"
  end

  def processed!(user_id)
    self.processed = true
    order_form.processed_at = DateTime.now
    if order_form.save && save
      events.create event: :order_processed, user_id: user_id
    end
  end

  def plan_type_string
    if plan_type == 1
      'Letna naročnina'
    elsif plan_type == 6
      'Plačilo za vsako posamezno številko'
    end
  end

  def to_s
    "Naročilo ##{id} (#{title || name})"
  end

  private

  def validate_plan_type
    return unless quantity? || plan_type?

    if quantity == 1 && plan_type == 6
      errors.add :plan_type, "za plačevanje po posamezni številki mora biti naročena količina vsaj 2"
    end
  end

  def create_order_form
    order_form = build_order_form
    order_form.issued_at = created_at
    order_form.form_id = "Naročilo ##{id}"
    order_form.save
  end
end
