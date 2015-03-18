require 'strava/api/v3'


class StravaHelper

  attr_reader :name, :activity_type

  def initialize(name, access_token)
    @name = name
    @client = Strava::Api::V3::Client.new(:access_token => access_token)
  end

  def get_activities(activity_type)
    @client.list_athlete_activities(:activity_type => activity_type.to_s)
  end

end

class StravaActivityToEvent

  def initialize(activity, object_tags, action_tags, timestamp_field, property_name, metric)
    @activity = activity
    @object_tags = object_tags
    @action_tags = action_tags
    @timestamp_field = timestamp_field
    @property_name = property_name
    @metric = metric
  end

  def to_event
    metric_value = @activity[@property_name]/1000
    timestamp = @activity[@timestamp_field]

    {
        "dateTime" => timestamp,
        "objectTags" => @object_tags.join(','),
        "actionTags" => @action_tags.join(','),
        "properties" => {
            @metric.to_s => metric_value
        }
    }
  end

end
