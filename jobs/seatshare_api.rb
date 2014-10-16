require 'net/http'
require 'uri'
require 'json'

seatshare_admin_api_url = ENV['SEATSHARE_ADMIN_API_URL']
seatshare_admin_api_key = ENV['SEATSHARE_ADMIN_API_KEY']
seatshare_admin_api_version = 'v1'

use_ssl = !!seatshare_admin_api_url.match("https")

# User Count
SCHEDULER.every '5m', :first_in => 0 do |job|

  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/user_count?api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']
 
  send_event('user_count', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/group_count?api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('group_count', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/total_invites?days=30&api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('total_invites', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/accepted_invites?days=30&api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('accepted_invites', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/recent_users?api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  users = JSON.parse(response.body)['data']
  puts users.inspect
  response = users.map do |row|
    row = {
      :label => "#{row['first_name']} #{row['last_name']}",
      :value => DateTime.parse(row['created_at']).strftime('%-m/%-d')
    }
  end
  puts response.inspect
  send_event('recent_users', { items: response } )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/recent_groups?api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  groups = JSON.parse(response.body)['data']

  response = groups.map do |row|
    row = {
      :label => row['group_name'],
      :value => DateTime.parse(row['created_at']).strftime('%-m/%-d')
    }
  end

  send_event('recent_groups', { items: response } )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/total_tickets?api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('total_tickets', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|
  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/tickets_transferred?days=30&api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('tickets_transferred', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|
  uri = URI("#{seatshare_admin_api_url}/#{seatshare_admin_api_version}/tickets_unused?days=30&api_key=#{seatshare_admin_api_key}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = use_ssl
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['data']

  send_event('tickets_unused', { current: count} )

end