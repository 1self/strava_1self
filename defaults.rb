
module Defaults
  extend self

  def from_file(fname)
    content = File.read(fname)
    content.strip
  end

  SESSION_SECRET = from_file("session_secret.txt")
  STRAVA_CLIENT_ID = from_file("strava_client_id.txt")
  STRAVA_CLIENT_SECRET = from_file("strava_client_secret.txt")
end


$stdout.sync = true #enable realtime logs on heroku

configure do
  enable :sessions
  set :session_secret, Defaults::SESSION_SECRET
  set :logging, true
end


use OmniAuth::Builder do
  provider :strava, Defaults::STRAVA_CLIENT_ID, Defaults::STRAVA_CLIENT_SECRET
end
