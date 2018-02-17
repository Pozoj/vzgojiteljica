# frozen_string_literal: true
class OrderForm < ActiveRecord::Base
  has_attached_file :document,
                    whiny: false,
                    storage: :s3,
                    bucket: AWS_S3['bucket'],
                    s3_credentials: {
                      access_key_id: AWS_S3['access_key_id'],
                      secret_access_key: AWS_S3['secret_access_key']
                    },
                    s3_permissions: {
                      original: :private,
                      preview: :public_read
                    },
                    s3_storage_class: :reduced_redundancy,
                    path: '/order_forms/:year/:id_:basename_:style.:extension',
                    styles: { preview: { geometry: '150x150>', format: :jpg } }

  validates_attachment_content_type :document, content_type: [/\Aimage\/.*\Z/, 'application/pdf']

  validates_presence_of :form_id

  Paperclip.interpolates :year do |attachment, _style|
    # TODO: remove this after 2015 is done to remove ambiguity
    date = attachment.instance.issued_at || attachment.instance.created_at
    date.year.to_s
  end

  belongs_to :customer
  belongs_to :order
  belongs_to :offer
  has_many :subscriptions
  has_many :remarks, as: :remarkable, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy

  scope :not_processed, -> { where(processed_at: nil) }
  scope :active, -> { where(arel_table[:start].lteq(Date.today).and(arel_table[:end].eq(nil).or(arel_table[:end].gteq(Date.today)))) }
  scope :inactive, -> { where(arel_table[:end].not_eq(nil).and(arel_table[:end].lteq(Date.today).or(arel_table[:start].gteq(Date.today)))) }

  before_save :set_year, if: :issued_at?

  def to_s
    form_id
  end

  def label_description
    parts = [form_id]
    parts.push "(#{issued_at})" if issued_at
    if order
      if order.title.present?
        parts.push order.title
      else
        parts.push order.name
      end
    elsif customer
      parts.push customer.to_s
    end

    parts.join(' - ')
  end

  def self.years
    distinct(:year).order(year: :desc).pluck(:year).compact
  end

  def able_to_process_attach?
    return unless customer
    subs = customer.subscriptions.active.paid
    return unless subs.any?

    subs.none?(&:order_form)
  end

  def process_attach!(user_id: nil)
    return unless able_to_process_attach?

    OrderForm.transaction do
      customer.subscriptions.active.paid.each do |subscription|
        next if subscription.order_form
        subscription.order_form = self
        subscription.save!
      end

      processed!(user_id: user_id)
    end
  end

  def able_to_process_renew?
    return unless customer
    subs = customer.subscriptions.active.paid
    return unless subs.any?

    return unless subs.none? { |subscription| subscription.order_form === self }
    subs.any?(&:order_form)
  end

  def process_renew!(user_id: nil)
    return unless able_to_process_renew?

    OrderForm.transaction do
      customer.subscribers.each do |subscriber|
        subs = subscriber.subscriptions.active.paid
        total_quantity = subs.sum(:quantity)

        next unless subs.any?

        # End all existing subscriptions.
        subs.each do |subscription|
          subscription.end = 1.year.ago.end_of_year
          subscription.events.create(event: :subscription_auto_canceled, details: id)
          subscription.remarks.create(remark: "Naročnina avtomatsko prekinjena zaradi procesiranja naročilnice ID #{id} (#{form_id})")
          subscription.save!
        end

        # Create a new subscription with combined quantity.
        new_sub = subs.first.dup
        new_sub.start = start || issued_at
        new_sub.end = self.end if end?
        new_sub.quantity = total_quantity
        new_sub.order_form = self
        new_sub.save!

        new_sub.events.create(event: :subscription_from_order_form, details: id)
        new_sub.remarks.create(remark: "Nova naročnina avtomatsko ustvarjena zaradi procesiranja naročilnice ID #{id} (#{form_id})")
        processed!(user_id: user_id)

        return new_sub
      end
    end
  end

  def processed!(user_id: nil)
    OrderForm.transaction do
      self.processed_at = DateTime.now
      save!

      if order && !order.processed?
        order.processed = true
        order.save!
      end

      events.create event: :order_form_processed, user_id: user_id
    end
  end

  def processed?
    processed_at && processed_at <= DateTime.now
  end

  def active?
    start && start >= DateTime.now && (!self.end || (self.end && self.end <= DateTime.now))
  end

  private

  def set_year
    self.year = issued_at.year
  end
end
