# For tuning the Content Security Policy, check the Decidim documentation site
# https://docs.decidim.org/en/develop/customize/content_security_policy

Rails.application.config.content_security_policy do |policy|
  policy.connect_src :self, "*.amazonaws.com", "*.hereapi.com", :data
end
