sidekiq_redis = { url: "#{ENV["REDIS_URL"]}#{ENV.fetch("REDIS_DB_FOR_SIDEKIQ")}" }

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis
end
Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis
end
