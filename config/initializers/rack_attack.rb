Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
  url: ENV["REDIS_URL"],
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)

class Rack::Attack
  # Safelist : laisser passer les crawlers de link preview
  # (ils ont besoin de rafales de requêtes pour HTML + images + redirects,
  # sinon Facebook/LinkedIn/etc. affichent une image grise dans les partages)
  safelist("allow-link-preview-bots") do |req|
    req.user_agent.to_s.match?(
      /facebookexternalhit|Facebot|FacebookBot|meta-externalagent|Twitterbot|LinkedInBot|Slackbot|WhatsApp|TelegramBot|Pinterest|Discordbot|Applebot/i
    )
  end

  # Rate-limit les pages de propositions avec filtres uniquement (crawlers)
  throttle("proposals-filtered/ip", limit: 15, period: 60) do |req|
    req.ip if req.path.include?("/proposals") && req.query_string.include?("filter")
  end

  # Rate-limit global par IP : 60 req/min (protège contre toute rafale)
  throttle("global/ip", limit: 60, period: 60) do |req|
    req.ip
  end

  self.throttled_responder = lambda do |request|
    [429, { "Content-Type" => "text/plain", "Retry-After" => "60" },
     ["Rate limit exceeded. Retry later.\n"]]
  end
end
