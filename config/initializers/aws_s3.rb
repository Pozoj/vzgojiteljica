# frozen_string_literal: true
AWS_S3 = if ENV['S3_B'] && ENV['S3_AK'] && ENV['S3_SAK']
           {
             'cdn' => ENV['S3_CDN'],
             'bucket' => ENV['S3_B'],
             'access_key_id' => ENV['S3_AK'],
             'secret_access_key' => ENV['S3_SAK']
           }.freeze
         else
           YAML.load_file("#{Rails.root}/config/s3.yml")[Rails.env]
         end
