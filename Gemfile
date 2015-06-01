source 'https://rubygems.org'

ruby '2.2.2'
gem 'rails', '~> 4.2.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 5.0.1'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'uglifier', '>= 2.7.0'
  gem 'asset_sync'
  gem 'chosen-rails'
  gem 'compass-rails', github: 'Compass/compass-rails'
  gem 'jquery-rails', '~> 4.0.3'
  gem 'jquery-ui-rails', '~> 5.0.3'
  gem 'jquery-fileupload-rails', '~> 0.4.3'
  gem 'sprockets', '2.11.0'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

gem 'pdfcrowd'
gem 'devise'
gem 'simple_form'
gem 'aws-sdk'
gem 'fog'
gem 'haml'
gem 'kaminari'
gem 'has_scope'
gem 'paperclip'
gem 'money-rails', github: 'RubyMoney/money-rails', ref: '46660b70e5e25e02a0e67f30a4a46b0139aff1a7'
gem 'gyoku', '~> 1.0'
gem 'iban-tools'
gem 'email_validator'
gem 'nokogiri'
gem 'levenshtein'
gem 'rubyzip'
gem 'rollbar'
gem 'cmxl'
gem 'sidekiq'
gem 'sinatra', require: nil
gem 'unicorn'

group :development, :test do
  gem 'sqlite3'
  gem 'pry'
  gem 'web-console'
  gem 'letter_opener'
  gem 'dotenv-rails'
  gem 'foreman'
end
