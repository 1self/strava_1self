require 'rest-client'
require 'time'

require_relative 'util'

module Oneself

  module Stream
    extend self

    def register(username, reg_token, strava_user_id)
      puts "#{strava_user_id}: #{username}: register: starting registration"

      callback_url = Defaults::HOST_URL + Defaults::SYNC_ENDPOINT + "?strava_uid=#{strava_user_id}&streamid={{streamid}}"
      puts "#{strava_user_id}: #{username}: register: post registration callback is #{callback_url}"

      app_id = Defaults::ONESELF_APP_ID
      app_secret = Defaults::ONESELF_APP_SECRET

      headers = {
        Authorization: "#{app_id}:#{app_secret}", 
        'registration-token' => reg_token,
        'content-type' => 'application/json'
      }

      stream_register_url = Defaults::ONESELF_API_HOST + sprintf(Defaults::ONESELF_STREAM_REGISTER_ENDPOINT, username)
      puts "#{strava_user_id}: #{username}: register: making request to register on #{stream_register_url}"
      resp = RestClient::Request.execute(
                                         method: :post,
                                         payload: {:callbackUrl => callback_url}.to_json,
                                         url: stream_register_url,
                                         headers: headers,
                                         accept: :json
                                         )

      puts "#{strava_user_id}: #{username}: register: successfully registered stream #{stream_register_url}"

      JSON.parse(resp)
    end
  end

  module Event
    extend self

    def transform_strava_event(evt)
      evt_type = evt["type"].downcase

      { 
        dateTime: evt["start_date"],
        objectTags: ['self'],
        actionTags: ['exercise', evt_type],
        properties: {
          distance: evt["distance"].to_i,
          name: evt["name"],
          "moving-duration" => evt["moving_time"],
          "elapsed-duration" => evt["elapsed_time"],
          "elevation-gain" => evt["total_elevation_gain"],
          city: evt["location_city"],
          state: evt["location_state"],
          country: evt["location_country"],
          "average-speed" => Util.mps_to_kph(evt["average_speed"]),
          "max-speed" => Util.mps_to_kph(evt["max_speed"])
        }
      }
    end

    def sync(type)
      [
       { dateTime: Time.now.utc.iso8601,
         objectTags: ['1self', 'integration', 'sync'],
         actionTags: [type],
         source: '1self-strava',
         properties: {
         }
       }
      ]
    end

    def send_via_api(events, stream)
      stream_id = stream["streamid"]
      puts "#{stream_id}: send_via_api: sending events to 1self"

      url = Defaults::ONESELF_API_HOST + 
        sprintf(Defaults::ONESELF_SEND_EVENTS_ENDPOINT, stream["streamid"])

      puts "#{stream_id}: send_via_api: url being used is #{url}"

      resp = RestClient.post(url, events.to_json, accept: :json, content_type: :json, Authorization: stream["writeToken"])
      
      puts "#{stream_id}: send_via_api: send response is #{resp.code}"
    end

  end

end
