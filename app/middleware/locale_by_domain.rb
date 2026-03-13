require 'rack/reverse_proxy'

class LocaleByDomain
  PRIMARY_HOST = 'www.ilot-lys.eu'
  NL_HOST = 'www.leie-eiland.eu'

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.host == NL_HOST
      env['HTTP_HOST'] = PRIMARY_HOST
      env['SERVER_NAME'] = PRIMARY_HOST
      env['HTTP_ORIGIN'] = env['HTTP_ORIGIN'].sub(NL_HOST, PRIMARY_HOST) if env['HTTP_ORIGIN']
      query = "locale=nl"
      query += "&#{request.query_string}" unless request.query_string.empty?
      env['QUERY_STRING'] = query
    elsif request.host == PRIMARY_HOST
      query = "locale=fr"
      query += "&#{request.query_string}" unless request.query_string.empty?
      env['QUERY_STRING'] = query
    end

    @app.call(env)
  end
end
