require('logger')

module Defaults
  extend self

  logger = Logger.new(STDOUT)

  def from_file(fname)
    content = File.read(fname)
    content.strip
  end

  SESSION_SECRET =  ENV['SESSION_SECRET']#from_file("session_secret.txt")
  HOST_URL = ENV['HOST_URL']#{}"https://oneself-strava.herokuapp.com"
  SYNC_ENDPOINT = "/sync"

  STRAVA_CLIENT_ID = ENV['STRAVA_CLIENT_ID']#from_file("strava_client_id.txt")
  STRAVA_CLIENT_SECRET = ENV['STRAVA_CLIENT_SECRET']#from_file("strava_client_secret.txt")

  ONESELF_API_HOST = ENV['ONESELF_API_HOST']#{}"http://api.1self.co"
  ONESELF_STREAM_REGISTER_ENDPOINT = "/v1/users/%s/streams"
  ONESELF_SEND_EVENTS_ENDPOINT = "/v1/streams/%s/events/batch"
  ONESELF_APP_ID = ENV['ONESELF_APP_ID']#from_file("oneself_app_id.txt")
  ONESELF_APP_SECRET = ENV['ONESELF_APP_SECRET']#from_file("oneself_app_secret.txt")

  STRAVA_DB_NAME=ENV['STRAVA_DB_NAME']
  STRAVA_DB_HOST=ENV['STRAVA_DB_HOST']
  STRAVA_DB_PORT=ENV['STRAVA_DB_PORT']
  STRAVA_DB_USER=ENV['STRAVA_DB_USER']
  STRAVA_DB_PASSWORD=ENV['STRAVA_DB_PASSWORD']

  logger.info('SESSION_SECRET: ' + SESSION_SECRET)
  logger.info('HOST_URL:' + HOST_URL)
  logger.info('STRAVA_CLIENT_ID: ' + STRAVA_CLIENT_ID)
  logger.info('ONESELF_API_HOST: ' + ONESELF_API_HOST)
  logger.info('ONESELF_APP_ID: ' + ONESELF_APP_ID)
  logger.info('ONESELF_APP_SECRET: ' + ONESELF_APP_SECRET)
  logger.info('STRAVA_DB_NAME: ' + STRAVA_DB_NAME)
  logger.info('STRAVA_DB_HOST: ' + STRAVA_DB_HOST)
  logger.info('STRAVA_DB_PORT: ' + STRAVA_DB_PORT)
  logger.info('STRAVA_DB_USER: ' + STRAVA_DB_USER)
  logger.info('STRAVA_DB_PASSWORD: ' + STRAVA_DB_PASSWORD)
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
