require 'sinatra/cyclist'

require 'dashing'

configure do
  set :auth_token, ENV['DASHING_AUTH_TOKEN']
  set :routes_to_cycle_through, [:seatshare_001, :seatshare_002]
  set :cycle_duration, 35
  set :default_dashboard, '_cycle'

  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['BASIC_AUTH_USERNAME'], ENV['BASIC_AUTH_PASSWORD']]
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end


run Sinatra::Application
