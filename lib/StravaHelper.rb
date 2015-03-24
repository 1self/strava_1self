require 'strava/api/v3'

class StravaHelper
  def initialize(access_token)
    @client = Strava::Api::V3::Client.new(:access_token => access_token)
  end
  
  def get_events(since_time)
    strava_events = @client.list_athlete_activities(after: since_time.to_i)
    transform_to_oneself_events(strava_events)
  end

  private
  
  def transform_to_oneself_events(strava_events)
    oneself_events = []
    strava_events.each do |evt|
      oneself_events.push(Oneself::Event.transform_strava_event(evt))
    end

    puts "Finished transforming events, returning."
    oneself_events
  end
end
