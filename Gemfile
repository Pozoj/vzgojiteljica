# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.3.3'
gem 'rails', '4.2.5.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 5.0.1'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'uglifier', '>= 2.7.0'
  gem 'compass-rails', github: 'Compass/compass-rails'
  gem 'jquery-rails', '~> 4.0.3'
  gem 'jquery-ui-rails', '~> 5.0.3'
  gem 'jquery-fileupload-rails', '~> 0.4.3'
  gem 'sprockets', '2.11.0'
  gem 'bootstrap-datepicker-rails', require: 'bootstrap-datepicker-rails', git: 'git://github.com/Nerian/bootstrap-datepicker-rails.git'
end

group :production do
  gem 'rails_12factor'
end

gem 'rack-attack'
gem 'pg'
gem 'pdfcrowd'
gem 'devise'
gem 'simple_form'
gem 'aws-sdk', '< 2.0'
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
gem 'rubyzip'
gem 'rollbar', '2.11.5'
gem 'cmxl'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sinatra', require: nil
gem 'unicorn'
gem 'newrelic_rpm'
gem 'scrolls'
gem 'redcarpet'

group :development do
  gem 'web-console'
  gem 'foreman'
end

group :development, :test do
  gem 'rubocop'
  gem 'dotenv-rails'
  gem 'pry'
  gem 'letter_opener'
  gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-commands-rspec'

  # Use rspec
  gem 'rspec-rails'
  gem 'guard-rspec', require: false
  gem 'factory_girl'
  gem 'timecop'
  gem 'capybara', '2.6.2'
end
