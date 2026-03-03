class LocaleByDomain
  DOMAIN_LOCALES = {
    'www.ilot-lys.eu'    => 'fr',
    'www.leie-eiland.eu' => 'nl'
  }.freeze

  PRIMARY_HOST = 'eurometropole-3e673cb05ad0.herokuapp.com'

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if (locale = DOMAIN_LOCALES[request.host])
      query = "locale=#{locale}"
      query += "&#{request.query_string}" unless request.query_string.empty?
      location = "https://#{PRIMARY_HOST}#{request.path}?#{query}"
      return [302, { 'Location' => location, 'Content-Type' => 'text/html' }, []]
    end
    @app.call(env)
  end
end
