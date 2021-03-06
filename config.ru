if File.exist? '.env'
  require 'dotenv'
  Dotenv.load
end

# Ensure everything is set up for authentication
fail 'Missing GITHUB_KEY' unless ENV['GITHUB_KEY']
fail 'Missing GITHUB_SECRET' unless ENV['GITHUB_SECRET']
fail 'Missing GITHUB_ORG_ID' unless ENV['GITHUB_ORG_ID']

require 'sinatra/cyclist'
require 'omniauth/strategies/github'
require 'octokit'
require 'dashing'

configure do
  set :auth_token, ENV['DASHING_AUTH_TOKEN']
  set :routes_to_cycle_through, [:seatshare_001, :seatshare_002]
  set :cycle_duration, 35
  set :default_dashboard, '_cycle'

  helpers do
    def protected!
      redirect '/auth/github' unless session[:user_id]
    end
  end

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'read:org'
  end

  get '/auth/github/callback' do
    organization_id = ENV['GITHUB_ORG_ID'].to_i

    auth = request.env['omniauth.auth']

    client = Octokit::Client.new access_token: auth['credentials']['token']
    user_orgs = client.user.rels[:organizations].get.data

    puts 'inspecting ...'
    puts user_orgs.inspect

    if user_orgs.any? { |org| org.id == organization_id }
      session[:user_id] = auth['info']['email']
      redirect '/'
    else
      redirect '/auth/failure'
    end
  end

  get '/auth/failure' do
    'Nope.'
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
