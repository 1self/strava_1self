require 'rest-client'
require 'time'

module Oneself

  module Stream
    extend self

    def register(username, reg_token, instagram_user_id)
      callback_url = Defaults::HOST_URL + Defaults::SYNC_ENDPOINT + "?instagram_uid=#{instagram_user_id}&streamid={{streamid}}"
      app_id = Defaults::ONESELF_APP_ID
      app_secret = Defaults::ONESELF_APP_SECRET

      headers = {Authorization: "#{app_id}:#{app_secret}", 'registration-token' => reg_token,
        'content-type' => 'application/json'}

      stream_register_url = Defaults::ONESELF_API_HOST + sprintf(Defaults::ONESELF_STREAM_ENDPOINT, username)

      resp = RestClient::Request.execute(
                                         method: :post,
                                         payload: {:callbackUrl => callback_url}.to_json,
                                         url: stream_register_url,
                                         headers: headers,
                                         accept: :json
                                         )

      puts "Successfully registered stream for #{username}"

      JSON.parse(resp)
    end
  end

  module Event
    extend self

    def run(evt)
      
    end

    def ride(evt)
      
    end

    def sync(type)
      [
       { dateTime: Time.now.utc.iso8601,
         objectTags: ['sync'],
         actionTags: [type],
         properties: {
           source: '1self-foursquare'
         }
       }
      ]
    end

    def send(events, stream)
      
    end

  end

end
