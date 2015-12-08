require 'net/http'
require 'uri'
require 'json'

api_url = ENV['SEATSHARE_ADMIN_API_URL']
api_key = ENV['SEATSHARE_ADMIN_API_KEY']
api_ver = 'v1'
use_ssl = true if api_url.match('https')

# User Count
SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/user_count?api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('user_count', current: count)
end

SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/group_count?api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('group_count', current: count)
end

SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/total_invites?days=30&api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('total_invites', current: count)
end

SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/accepted_invites?days=30&api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('accepted_invites', current: count)
end

SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/recent_users?api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  users = JSON.parse(response.body)['data'] || []

  response = users.map do |row|
    {
      label: "#{row['first_name']} #{row['last_name']}",
      value: DateTime.parse(row['created_at']).strftime('%-m/%-d')
    }
  end

  send_event('recent_users', items: response)
end

SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/recent_groups?api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  groups = JSON.parse(response.body)['data'] || []

  response = groups.map do |row|
    {
      label: row['group_name'],
      value: DateTime.parse(row['created_at']).strftime('%-m/%-d')
    }
  end

  send_event('recent_groups', items: response)
end

SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/total_tickets?api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('total_tickets', current: count)
end

SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/tickets_transferred?days=30&api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('tickets_transferred', current: count)
end

SCHEDULER.every '1m', first_in: 0 do
  uri = URI("#{api_url}/#{api_ver}/tickets_unused?days=30&api_key=#{api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('tickets_unused', current: count)
end
