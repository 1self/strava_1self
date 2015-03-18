module Constants

  CONFIG = {
      REFERENCE: {
          ONESELF_URL: 'https://sandbox.1self.co',
          POST_EVENTS_PATH_BEGINS: '/v1/streams',
          POST_EVENTS_PATH_ENDS: '/events/batch',
          ONESELF_APPLICATION_ID: 'app-id-3cbe82b7f4e2dcdf96c48d6743ec8b55',
          ONESELF_APPLICATION_SECRET: 'app-secret-eb44bdbea7ef01fe7211c00dd15704b3e966a8f46029a93bc8596c1da5a0f278'
      }
  }

  TAGS = {
      Ride: {
          OBJECT_TAGS: ['strava'],
          ACTION_TAGS: ['ride']
      },

      Run: {
          OBJECT_TAGS: ['strava'],
          ACTION_TAGS: ['run']
      }
  }

  def self.get_create_stream_url
    CONFIG[:REFERENCE][:ONESELF_URL] + CONFIG[:REFERENCE][:POST_EVENTS_PATH_BEGINS]
  end

  def self.get_post_events_url(stream_id)
    "#{CONFIG[:REFERENCE][:ONESELF_URL]}#{CONFIG[:REFERENCE][:POST_EVENTS_PATH_BEGINS]}/#{stream_id}#{CONFIG[:REFERENCE][:POST_EVENTS_PATH_ENDS]}"
  end

end