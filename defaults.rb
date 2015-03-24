
module Defaults
  extend self

  def from_file(fname)
    content = File.read(fname)
    content.strip
  end

  SESSION_SECRET = from_file("session_secret.txt")
  HOST_URL = "http://localhost:5000"
  SYNC_ENDPOINT = "/sync"

  STRAVA_CLIENT_ID = from_file("strava_client_id.txt")
  STRAVA_CLIENT_SECRET = from_file("strava_client_secret.txt")

  ONESELF_API_HOST = "http://api-staging.1self.co"
  ONESELF_STREAM_REGISTER_ENDPOINT = "/v1/users/%s/streams"
  ONESELF_SEND_EVENTS_ENDPOINT = "/v1/streams/%s/events/batch"
  ONESELF_APP_ID = from_file("oneself_app_id.txt")
  ONESELF_APP_SECRET = from_file("oneself_app_secret.txt")
end


$stdout.sync = true #enable realtime logs on heroku

configure do
  enable :sessions
  set :session_secret, Defaults::SESSION_SECRET
  set :logging, true
  set :server, 'webrick'
end


use OmniAuth::Builder do
  provider :strava, Defaults::STRAVA_CLIENT_ID, Defaults::STRAVA_CLIENT_SECRET
end
