# frozen_string_literal: true
class Issue < ActiveRecord::Base
  has_many :articles
  has_many :keywords, through: :articles
  belongs_to :batch

  validates :issue, numericality: { only_integer: true, greater_than: 0, less_than: 8 }

  scope :sorted, -> { order(year: :desc, issue: :asc) }

  has_attached_file :document,
                    whiny: false,
                    storage: :s3,
                    bucket: AWS_S3['bucket'],
                    s3_credentials: {
                      access_key_id: AWS_S3['access_key_id'],
                      secret_access_key: AWS_S3['secret_access_key']
                    },
                    s3_headers: {
                      'Cache-Control' => 'public, max-age=31557600',
                      'Expires' => 'Wed, 15 Apr 2020 13:37:00 GMT'
                    },
                    s3_host_alias: AWS_S3['cdn'],
                    s3_storage_class: :reduced_redundancy,
                    path: '/assets/issues/:id/document/:style_:basename.:extension',
                    url: ':s3_alias_url'

  has_attached_file :cover,
                    styles: {
                      medium: ['180x180>', :jpg],
                      original: ['960x720>', :jpg]
                    },
                    default_url: 'http://cdn.vzgojiteljica.si/assets/cover_missing-e2b823f1b45a2a7ba13f19aa60bf84cf.jpg',
                    convert_options: { all: '-strip -quality 75' },
                    whiny: false,
                    storage: :s3,
                    bucket: AWS_S3['bucket'],
                    s3_credentials: {
                      access_key_id: AWS_S3['access_key_id'],
                      secret_access_key: AWS_S3['secret_access_key']
                    },
                    s3_headers: {
                      'Cache-Control' => 'public, max-age=31557600',
                      'Expires' => 'Wed, 15 Apr 2020 13:37:00 GMT'
                    },
                    s3_host_alias: AWS_S3['cdn'],
                    s3_storage_class: :reduced_redundancy,
                    path: '/assets/issues/:id/cover/:style_:basename.:extension',
                    url: ':s3_alias_url'

  validates_attachment_content_type :document, content_type: 'application/pdf'
  validates_attachment_content_type :cover, content_type: %w(image/jpeg image/jpg)

  def articles_grouped_by_sections
    articles.joins(:section).order('sections.position').group_by(&:section)
  end

  def older_than_2_years?
    Date.today.year - year >= 2
  end

  def self.last
    Issue.order(year: :desc, issue: :desc).first
  end

  def to_s
    "#{year} / #{issue}."
  end

  def to_param
    "#{id}-leto-#{year}-stevilka-#{issue}"
  end
end
