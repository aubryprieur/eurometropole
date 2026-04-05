Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
  url: ENV["REDIS_URL"],
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)

class Rack::Attack
  # Limiter les requêtes sur les pages de propositions : 5 par minute par IP
  throttle("proposals/ip", limit: 5, period: 60) do |req|
    req.ip if req.path.include?("/proposals")
  end

  # Limiter le crawl global du sous-réseau Facebook : 20 req/min par IP
  throttle("facebook-crawler/ip", limit: 20, period: 60) do |req|
    req.ip if req.ip&.start_with?("57.141.")
  end

  # Réponse 429 personnalisée
  self.throttled_responder = lambda do |req|
    [429, { "Content-Type" => "text/plain", "Retry-After" => "60" }, ["Rate limit exceeded. Retry later.\n"]]
  end
end
