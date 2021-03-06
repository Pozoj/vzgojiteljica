# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

module Web3
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Ljubljana'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :sl

    config.assets.precompile += ['print.css', 'admin.css', 'admin_print.css', 'upload.js', 'admin.js']

    config.autoload_paths << Rails.root.join('lib')

    config.middleware.use Rack::Attack

    config.action_controller.permit_all_parameters = true

    config.active_record.raise_in_transactional_callbacks = true
  end
end
