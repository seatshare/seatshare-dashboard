require 'mailchimp'

SCHEDULER.every '5m', first_in: 0 do |job|
  mailchimp = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
  campaign_list = mailchimp.campaigns.list
  cid = campaign_list['data'][0]['id']
  response = mailchimp.reports.summary(cid)
  send_event('mailchimp', {
    uniq_opens:   response['unique_opens'],
    uniq_clicks:  response['unique_clicks'],
    sent:         response['emails_sent'],
    unsubscribes: response['unsubscribes']
  })
end
