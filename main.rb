require 'sinatra'
require "sinatra/reloader"
require 'omniauth'
require 'omniauth-strava-oauth2'
require 'pg'
require 'byebug'

require_relative 'defaults'
require_relative 'lib/Oneself'
require_relative 'lib/StravaHelper'

get '/' do
  "There's nothing here."
end

get '/login' do
  session['oneselfUsername'] = params[:username]
  session['registrationToken'] = params[:token]
  puts "Redirecting #{params[:username]} to login."

  redirect to("/auth/strava")
end

get '/sync' do
  strava_id = params[:strava_uid]
  streamid = params[:streamid]
  write_token = request.env['HTTP_AUTHORIZATION']

  stream = {
    "streamid": streamid,
    "writeToken": write_token
  }

  start_sync(strava_id, stream)
end


get '/auth/strava/callback' do
  begin
    strava_user_id = request.env['omniauth.auth']['uid']
    username = request.env['omniauth.auth']['info']['firstname']
    auth_token = request.env['omniauth.auth']['credentials']['token']

    last_sync_time = (DateTime.now << 1).to_time.to_i
    conn = PG::Connection.open(:dbname => 'dev')
    conn.exec_params('INSERT INTO USERS (name, strava_id, access_token, last_sync_time) VALUES ($1, $2, $3, $4)', [username, strava_user_id.to_i, auth_token, last_sync_time])
    
    stream = Oneself::Stream.register(session['oneselfUsername'],
                                      session['registrationToken'],
                                      strava_user_id
                                      )

    start_sync(strava_user_id, stream)

    redirect(Defaults::ONESELF_API_HOST + '/integrations')
  rescue => e
    puts "Error while strava callback #{e}"
  end
end


def start_sync(strava_id, stream)
  sync_start_event = Oneself::Event.sync("start")
  Oneself::Event.send_via_api(sync_start_event, stream)
  puts "Sent sync start event successfully"

  conn = PG::Connection.open(:dbname => 'dev')
  result = conn.exec("SELECT * FROM USERS WHERE STRAVA_ID = '#{strava_id}'")
  
  auth_token = result[0]["access_token"]
  username = result[0]["name"]
  since_time = result[0]["last_sync_time"]

  puts "Fetching events for #{username}"
  strava_helper = StravaHelper.new(auth_token)

  all_events = strava_helper.get_events(since_time) +
    Oneself::Event.sync("complete")

  Oneself::Event.send_via_api(all_events, stream)

  result = conn.exec("UPDATE USERS SET LAST_SYNC_TIME = #{Time.now.to_i} WHERE STRAVA_ID = '#{strava_id}'")
  puts "Sync complete for #{username}"

rescue => e
  puts "Some error for: #{strava_id}. Error: #{e}"
end
