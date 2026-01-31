Decidim.configure do |config|
  config.direct_upload = false

  config.content_security_policy do |policy|
    policy.connect_src :self, "*.amazonaws.com", "*.hereapi.com", :data
  end
end
