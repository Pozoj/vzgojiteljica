# frozen_string_literal: true
if ENV['S3_B'] && ENV['S3_AK'] && ENV['S3_SAK']
  AWS_S3 = {
    'cdn' => ENV['S3_CDN'],
    'bucket' => ENV['S3_B'],
    'access_key_id' => ENV['S3_AK'],
    'secret_access_key' => ENV['S3_SAK']
  }.freeze
else
  AWS_S3 = YAML.load_file("#{Rails.root}/config/s3.yml")[Rails.env]
end
