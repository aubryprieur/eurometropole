# config/initializers/sidekiq.rb
require "sidekiq"
require "openssl"

redis_url = ENV["REDIS_TLS_URL"]
redis_url = ENV["REDIS_URL"] if redis_url.nil? || redis_url.empty?

redis_opts = {
  url: redis_url,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_PEER }
}

Sidekiq.configure_server { |config| config.redis = redis_opts }
Sidekiq.configure_client { |config| config.redis = redis_opts }
