class Issue < ActiveRecord::Base
  has_many :articles
  has_many :keywords, through: :articles

  default_scope order('year DESC, issue DESC')

  has_attached_file :document,
                    :whiny => false,
                    :storage => :s3,
                    :bucket => AWS_S3['bucket'],
                    :s3_credentials => {
                      :access_key_id => AWS_S3['access_key_id'],
                      :secret_access_key => AWS_S3['secret_access_key']
                    },
                    :s3_headers => {
                      'Cache-Control' => 'public, max-age=31557600',
                      'Expires' => 'Wed, 15 Apr 2020 13:37:00 GMT'
                    },
                    :s3_storage_class => :reduced_redundancy,
                    :path => "/assets/issues/:id/document/:style_:basename.:extension"

  has_attached_file :cover,
                    :styles => { 
                      :medium => ["180x180>", :jpg], 
                      :original => ["960x720>", :jpg]
                    },
                    :default_url => '/assets/cover_missing.jpg',
                    :convert_options => { :all => "-strip -quality 75"},
                    :whiny => false,
                    :storage => :s3,
                    :bucket => AWS_S3['bucket'],
                    :s3_credentials => {
                      :access_key_id => AWS_S3['access_key_id'],
                      :secret_access_key => AWS_S3['secret_access_key']
                    },
                    :s3_headers => {
                      'Cache-Control' => 'public, max-age=31557600',
                      'Expires' => 'Wed, 15 Apr 2020 13:37:00 GMT'
                    },
                    :s3_storage_class => :reduced_redundancy,
                    :path => "/assets/issues/:id/cover/:style_:basename.:extension"

  def articles_grouped_by_sections
    articles.joins(:section).order('sections.position').group_by { |a| a.section }
  end

  def older_than_2_years?
    Date.today.year - year >= 2
  end

  def to_s
    "#{year} / #{issue}."
  end

  def to_param
    "#{id}-leto-#{year}-stevilka-#{issue}"
  end
end