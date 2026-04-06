# frozen_string_literal: true

# Add a 60-minute time bucket to ActivityCell#cache_hash so that
# relative timestamps ("il y a X minutes") refresh hourly instead
# of staying frozen in Redis cache for up to 24h.
Rails.application.config.to_prepare do
  Decidim::ActivityCell.class_eval do
    def cache_hash
      hash = []
      hash << id_prefix
      hash << I18n.locale.to_s
      hash << model.class.name.underscore
      hash << model.cache_key_with_version if model.respond_to?(:cache_key_with_version)
      hash << (Time.current.to_i / 60.minutes.to_i).to_s

      hash.join(Decidim.cache_key_separator)
    end
  end
end
