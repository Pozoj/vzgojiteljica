source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '4.0.0.beta1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0.beta1'
  gem 'uglifier', '>= 1.0.3'
  gem 'asset_sync'
end

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-rails'

group :production do
  gem 'pg'
  gem 'therubyracer-heroku'
  gem 'unicorn'
end

gem 'devise', :git => 'https://github.com/plataformatec/devise.git', :branch => 'rails4'
gem 'inherited_resources'
gem 'simple_form', '3.0.0.beta1'
gem 'paperclip'
gem 'aws-sdk'
gem 'haml'

group :development, :test do
  gem 'sqlite3'
end