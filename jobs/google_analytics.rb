require 'google/api_client'
require 'date'

# Update these to match your own apps credentials
service_account_email = ENV['GOOGLE_SERVICE_ACCOUNT_EMAIL']
google_private_key = ENV['GOOGLE_PRIVATE_KEY']
google_private_key_secret = ENV['GOOGLE_PRIVATE_KEY_SECRET']
profileID = ENV['GOOGLE_ANALYTICS_PROFILE_ID']

# Get the Google API client
client = Google::APIClient.new(:application_name => 'Dashing', 
  :application_version => '0.01')

# Load your credentials for the service account
begin
  key = OpenSSL::PKey::RSA.new google_private_key, google_private_key_secret
  client.authorization = Signet::OAuth2::Client.new(
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
    :audience => 'https://accounts.google.com/o/oauth2/token',
    :scope => 'https://www.googleapis.com/auth/analytics.readonly',
    :issuer => service_account_email,
    :signing_key => key)
rescue
    puts "\e[33mFor the Google Analytics widget to work, you must complete the configuration steps (including a private key).\e[0m"
end

# Start the scheduler
SCHEDULER.every '20s', :first_in => 0 do

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Start and end dates
  startDate = DateTime.now.strftime("%Y-%m-01") # first day of current month
  endDate = DateTime.now.strftime("%Y-%m-%d")  # now

  # Execute the queries
  visitorCount = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
    'ids' => "ga:" + profileID, 
    'start-date' => startDate,
    'end-date' => endDate,
    'metrics' => "ga:visitors"
  })
  userSignups = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
    'ids' => "ga:" + profileID, 
    'start-date' => startDate,
    'end-date' => endDate,
    'metrics' => "ga:goal1Completions",
  })

  puts userSignups.data.rows.inspect

  # Update the dashboard
  send_event('ga_visitor_count',  { current: visitorCount.data.rows.count > 0 ? visitorCount.data.rows[0][0] : 0 })
  send_event('ga_goal_signup',   { current: userSignups.data.rows.count > 0 ? userSignups.data.rows[0][0] : 0 })
end