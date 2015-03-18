require 'rest-client'
require_relative 'constants'


class OneselfHelper

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def write_events(events)
    stream_id = get_stream_id
    write_token = get_write_token
    url = Constants::get_post_events_url(stream_id)

    headers = {
        content_type: :json,
        accept: :json,
        Authorization: write_token
    }

    RestClient.post(
        url,
        events.to_json,
        headers
    )
  end

  def get_visualisation_url(object_tags, action_tags, metric, aggregation_name, time_bucket, visualisation)
    "#{Constants::CONFIG[:REFERENCE][:ONESELF_URL]}#{Constants::CONFIG[:REFERENCE][:POST_EVENTS_PATH_BEGINS]}/#{get_stream_id}/events/#{object_tags.join(',')}/#{action_tags.join(',')}/#{aggregation_name}(#{metric})/#{time_bucket}/#{visualisation}"
  end

  private

  def get_stream_id
    get_stream['streamid']
  end

  def get_write_token
    get_stream['writeToken']
  end

  def get_read_token
    get_stream['readToken']
  end

  def get_stream
    unless @stream
      url = Constants::get_create_stream_url

      application_id = Constants::CONFIG[:REFERENCE][:ONESELF_APPLICATION_ID]
      application_secret = Constants::CONFIG[:REFERENCE][:ONESELF_APPLICATION_SECRET]
      headers = {
          content_type: :json,
          accept: :json,
          Authorization: "#{application_id}:#{application_secret}"
      }

      response = RestClient.post(
          url,
          {}.to_json,
          headers
      )
      @stream = JSON.parse(response)
    else
      @stream
    end
  end

end
