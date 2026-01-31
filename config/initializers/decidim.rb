Decidim.configure do |config|
  config.direct_upload = false

  config.content_security_policies_extra = {
    "connect-src" => %w(https://eurometropole-decidim.s3.eu-west-3.amazonaws.com),
    "img-src" => %w(https://eurometropole-decidim.s3.eu-west-3.amazonaws.com),
    "media-src" => %w(https://eurometropole-decidim.s3.eu-west-3.amazonaws.com)
  }
end
