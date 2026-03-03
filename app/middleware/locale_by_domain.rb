class LocaleByDomain
  PRIMARY_HOST = 'www.ilot-lys.eu'
  NL_HOST = 'www.leie-eiland.eu'

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.host == NL_HOST
      query = "locale=nl"
      query += "&#{request.query_string}" unless request.query_string.empty?
      location = "https://#{PRIMARY_HOST}#{request.path}?#{query}"
      return [302, { 'Location' => location, 'Content-Type' => 'text/html' }, []]
    end

    @app.call(env)
  end
end
