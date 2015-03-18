require_relative 'strava_helper'
require_relative 'oneself_helper'
require_relative 'constants'


print "We'll fetch activity information for you from Strava, and post them to 1self.co"
puts
print "Your name: "; name = gets.chomp
print "Paste your Strava API access token: "; access_token = gets.chomp
print "Choose 1 to fetch biking activities, or 2 for running: "; activity_type = gets.chomp == '1' ? :Ride : :Run

strava_helper = StravaHelper.new(name, access_token)
activities = strava_helper.get_activities(activity_type)

object_tags, action_tags = [Constants::TAGS[activity_type][:OBJECT_TAGS], Constants::TAGS[activity_type][:ACTION_TAGS]]
timestamp_field, property_name, metric, aggregation_name = ['start_date', 'distance', 'km', 'sum']

events = activities.collect { |activity|
  StravaActivityToEvent.new(activity, object_tags, action_tags, timestamp_field, property_name, metric).to_event
}

oneself_helper = OneselfHelper.new('mine')
oneself_helper.write_events(events)

time_bucket, visualisation = ['daily', 'barchart']

puts 'View your activities at the following URL: '
puts oneself_helper.get_visualisation_url(object_tags, action_tags, metric, aggregation_name, time_bucket, visualisation)
