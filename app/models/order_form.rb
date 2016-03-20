class OrderForm < ActiveRecord::Base
  has_attached_file :document,
                    :whiny => false,
                    :storage => :s3,
                    :bucket => AWS_S3['bucket'],
                    :s3_credentials => {
                      :access_key_id => AWS_S3['access_key_id'],
                      :secret_access_key => AWS_S3['secret_access_key']
                    },
                    :s3_permissions => {
                      :original => :private,
                      :preview => :public_read
                    },
                    :s3_storage_class => :reduced_redundancy,
                    :path => "/order_forms/:year/:id_:basename_:style.:extension",
                    :styles => { :preview => { :geometry => '150x150>',  :format => :jpg } }

  validates_attachment_content_type :document, content_type: [/\Aimage\/.*\Z/, 'application/pdf']

  validates_presence_of :form_id

  Paperclip.interpolates :year do |attachment, style|
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

  before_save :set_year, if: :issued_at?

  def to_s
    form_id
  end

  def label_description
    parts = [form_id]
    if issued_at
      parts.push "(#{issued_at})"
    end
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
    self.distinct(:year).order(year: :desc).pluck(:year).compact
  end

  def processed!(user_id: nil)
    OrderForm.transaction do
      self.processed_at = DateTime.now
      save!
      events.create event: :order_form_processed, user_id: user_id
    end
  end

  def processed?
    processed_at && processed_at <= DateTime.now
  end

  private

  def set_year
    self.year = issued_at.year
  end
end
