#!/usr/bin/env ruby
require 'rest-client'
require 'json'
require 'date'

github_token = ENV['GITHUB_TOKEN']
github_owner = ENV['GITHUB_OWNER']
github_project = ENV['GITHUB_PROJECT']

SCHEDULER.every '10m', :first_in => 0 do |job|
    uri = "https://api.github.com/repos/#{github_owner}/#{github_project}/milestones?access_token=#{github_token}"
    puts "Getting #{uri}"
    response = RestClient.get uri
    milestones = JSON.parse(response.body, symbolize_names: true)

    # Remove all the milestones with no due date, or where all the issues are closed.
    milestones.select! { |milestone| !milestone[:due_on].nil? and (milestone[:open_issues] > 0) }

    if milestones.length > 0
        milestones.sort! { |a,b| a[:due_on] <=> b[:due_on] }

        next_milestone = milestones.first
        days_left = (Date.parse(next_milestone[:due_on]) - Date.today).to_i
        if days_left > 0
            due = "Due in #{days_left} days"
        elsif days_left == 0
            due = "Due today"
        else
            due = "Overdue by #{days_left.abs} days"
        end

        send_event('github_next_milesone', {
            text: "#{next_milestone[:title] or 'Unnamed Milestone'}<br>#{due}",
            moreinfo: "#{next_milestone[:open_issues]}/#{next_milestone[:open_issues] + next_milestone[:closed_issues]} issues remain"
        })

    else
        # There are no milestones left with open issues.
        send_event('github_next_milesone', {
            text: "None",
            moreinfo: ""
        })

    end
end # SCHEDULER