require 'net/http'
require 'uri'
require 'json'

$hostname = ENV['SEATSHARE_ADMIN_API_URL']
$api_key = ENV['SEATSHARE_ADMIN_API_KEY']

# User Count
SCHEDULER.every '5m', :first_in => 0 do |job|

  uri = URI($hostname + '/api/dashing/user_count?key='+$api_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['count']
 
  send_event('user_count', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI($hostname + '/api/dashing/group_count?key='+$api_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['count']

  send_event('group_count', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI($hostname + '/api/dashing/total_invites?key='+$api_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['count']

  send_event('total_invites', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI($hostname + '/api/dashing/accepted_invites?key='+$api_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['count']

  send_event('accepted_invites', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI($hostname + '/api/dashing/largest_groups?key='+$api_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  puts response.inspect

  groups = JSON.parse(response.body)

  acctitems = groups.map do |row|
    row = {
      :label => row['group'],
      :value => row['user_count']
    }
  end

  send_event('largest_groups', { items: acctitems } )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI($hostname + '/api/dashing/total_tickets?key='+$api_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['count']

  send_event('total_tickets', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI($hostname + '/api/dashing/tickets_transferred?days=30&key='+$api_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['count']

  send_event('tickets_transferred', { current: count} )

end

SCHEDULER.every '15m', :first_in => 0 do |job|

  uri = URI($hostname + '/api/dashing/tickets_unused?days=30&key='+$api_key)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  count = JSON.parse(response.body)['count']

  send_event('tickets_unused', { current: count} )

end