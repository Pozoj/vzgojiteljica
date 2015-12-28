if Rails.env.development? || Rails.env.test?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://boot2docker/sidekiq' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://boot2docker/sidekiq' }
  end
end

schedule_file = File.expand_path('../../schedule.yml', __FILE__)

if File.exists?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
