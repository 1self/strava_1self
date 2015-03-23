require 'strava/api/v3'

class StravaHelper
  def initialize(access_token)
    @client = Strava::Api::V3::Client.new(:access_token => access_token)
  end
  
  def get_events(type)
    strava_events = @client.list_athlete_activities(:activity_type => type)
    transform_to_oneself_events(strava_events, type)
  end

  private
  
  def transform_to_oneself_events(strava_events, type)
    oneself_events = []
    strava_events.each do |evt|
      oneself_events.push(Oneself::Event.send(type, evt))
    end

    oneself_events
  end
end
