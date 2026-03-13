require 'rack/reverse_proxy'

class LocaleByDomain
  PRIMARY_HOST = 'www.ilot-lys.eu'
  NL_HOST = 'www.leie-eiland.eu'

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    original_host = request.host

    if original_host == NL_HOST
      env['HTTP_HOST'] = PRIMARY_HOST
      env['SERVER_NAME'] = PRIMARY_HOST
      env['HTTP_ORIGIN'] = env['HTTP_ORIGIN'].sub(NL_HOST, PRIMARY_HOST) if env['HTTP_ORIGIN']
      query = "locale=nl"
      query += "&#{request.query_string}" unless request.query_string.empty?
      env['QUERY_STRING'] = query
    elsif original_host == PRIMARY_HOST
      query = "locale=fr"
      query += "&#{request.query_string}" unless request.query_string.empty?
      env['QUERY_STRING'] = query
    end

    status, headers, response = @app.call(env)

    # Rewrite redirect URLs back to the original NL domain
    if original_host == NL_HOST && headers['Location']
      headers['Location'] = headers['Location'].gsub(PRIMARY_HOST, NL_HOST)
    end

    # Rewrite HTML body links so NL visitors stay on leie-eiland.eu
    if original_host == NL_HOST && headers['Content-Type']&.include?('text/html')
      body = +""
      response.each { |chunk| body << chunk }
      response.close if response.respond_to?(:close)

      body.gsub!("https://#{PRIMARY_HOST}", "https://#{NL_HOST}")
      body.gsub!("http://#{PRIMARY_HOST}", "http://#{NL_HOST}")

      headers['Content-Length'] = body.bytesize.to_s
      response = [body]
    end

    [status, headers, response]
  end
end
