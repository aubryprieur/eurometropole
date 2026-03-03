class LocaleByDomain
  DOMAIN_LOCALES = {
    'www.ilot-lys.eu'    => 'fr',
    'www.leie-eiland.eu' => 'nl'
  }.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if (locale = DOMAIN_LOCALES[request.host])
      env['QUERY_STRING'] = "locale=#{locale}&#{env['QUERY_STRING']}"
    end
    @app.call(env)
  end
end
