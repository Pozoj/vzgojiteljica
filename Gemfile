source 'https://rubygems.org'

ruby '2.1.4'
gem 'rails', '~> 4.1.8'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.0.3'
  gem 'asset_sync'
  gem 'chosen-rails'
  gem 'compass-rails', github: 'Compass/compass-rails'
  gem 'jquery-rails', '~> 2.3.0'
  gem 'sprockets', '2.11.0'
end

group :production do
  gem 'pg'
  gem 'unicorn'
end

gem 'devise'
gem 'inherited_resources'
gem 'simple_form', '~> 3.1.0.rc2'
gem 'paperclip'
gem 'aws-sdk'
gem 'haml'
gem 'kaminari'
gem 'has_scope'

group :development, :test do
  gem 'sqlite3'
  gem 'pry'
end
