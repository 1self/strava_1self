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
  if params[:username].nil? || params[:token].nil?
    puts "/login: request was made without oneself parameters"
    status 404
    body 'Oneself parameters not found' and return
  end

  session['oneselfUsername'] = params[:username]
  session['registrationToken'] = params[:token]
  session['redirectUri'] = params[:redirect_uri]
  puts "#{session['oneselfUsername']}: /login: request received, redirect uri is #{session['redirectUri']}"

  stravaUrl = Defaults::HOST_URL + "/auth/strava"
  puts "#{session['oneselfUsername']}: /login: redirecting to strava on stravaUrl"
  redirect to(stravaUrl)
end

get '/sync' do
  strava_id = params[:strava_uid]
  streamid = params[:streamid]
  write_token = request.env['HTTP_AUTHORIZATION']

  if strava_id.nil? || streamid.nil? || write_token.nil?
    puts "/sync: request was made without oneself parameters"
    status 404
    body 'Oneself sync parameters not found' and return
  end

  puts "#{strava_id}: #{streamid}: /sync: starting request"

  stream = {
    "streamid" => streamid,
    "writeToken" => write_token
  }

  start_sync(strava_id, stream)

  puts "#{strava_id}: #{streamid}: /sync: request complete"
end


get '/auth/strava/callback' do
  begin
    strava_user_id = request.env['omniauth.auth']['uid']
    username = request.env['omniauth.auth']['info']['firstname']
    puts "#{strava_user_id}: #{username}: /auth/strava/callback: fetching events"

    auth_token = request.env['omniauth.auth']['credentials']['token']

    last_sync_time = (DateTime.now << 1).to_time.to_i
    puts "#{strava_user_id}: #{username}: /auth/strava/callback: last sync time is #{last_sync_time}"

    conn = PG::Connection.open(dbname: Defaults::STRAVA_DB_NAME,
                              host: Defaults::STRAVA_DB_HOST,
                              port: Defaults::STRAVA_DB_PORT.to_i,
                              user: Defaults::STRAVA_DB_USER,
                              password: Defaults::STRAVA_DB_PASSWORD)

    conn.exec_params('INSERT INTO USERS (name, strava_id, access_token, last_sync_time) VALUES ($1, $2, $3, $4)', [username, strava_user_id.to_i, auth_token, last_sync_time])
    puts "#{strava_user_id}: #{username}: /auth/strava/callback: database updated succesfully"
    
    stream = Oneself::Stream.register(session['oneselfUsername'],
                                      session['registrationToken'],
                                      strava_user_id
                                      )
    puts "#{strava_user_id}: #{username}: /auth/strava/callback: stream registered"
    
    start_sync(strava_user_id, stream)
    puts "#{strava_user_id}: #{username}: /auth/strava/callback: sync start sent"

    successRedirect = session['redirectUri'] + "?success=true";
    puts "#{strava_user_id}: #{username}: /auth/strava/callback: redirecting to #{successRedirect}"
    redirect(successRedirect)

  rescue => e
    puts "Error while strava callback #{e}"
    redirect(session['redirectUri'] + "?success=false&error=server_error")
  end
end

def start_sync(strava_id, stream)
  puts "#{strava_id}: start_sync: starting sync"

  sync_start_event = Oneself::Event.sync("start")
  Oneself::Event.send_via_api(sync_start_event, stream)
  puts "#{strava_id}: start_sync: sync start sent"

  conn = PG::Connection.open(dbname: Defaults::STRAVA_DB_NAME,
                              host: Defaults::STRAVA_DB_HOST,
                              port: Defaults::STRAVA_DB_PORT.to_i,
                              user: Defaults::STRAVA_DB_USER,
                              password: Defaults::STRAVA_DB_PASSWORD)
  result = conn.exec_params("SELECT * FROM USERS WHERE STRAVA_ID = $1", [strava_id])
  
  auth_token = result[0]["access_token"]
  username = result[0]["name"]
  since_time = result[0]["last_sync_time"]

  puts "#{strava_id}: #{username}: start_sync: details retreived from database, last sync time is #{since_time}"
  
  puts "#{strava_id}: #{username}: start_sync: fetching events"
  strava_helper = StravaHelper.new(auth_token)
  all_events = strava_helper.get_events(since_time) + Oneself::Event.sync("complete")
  puts "#{strava_id}: #{username}: start_sync: sending events"
  Oneself::Event.send_via_api(all_events, stream)

  new_last_sync_date = Time.now.to_i 
  puts "#{strava_id}: #{username}: start_sync: updating database with last sync time of #{new_last_sync_date}"
  result = conn.exec_params("UPDATE USERS SET LAST_SYNC_TIME = $1 WHERE STRAVA_ID = $2", [new_last_sync_date, strava_id])
  puts "#{strava_id}: #{username}: start_sync: database updated"
  puts "#{strava_id}: #{username}: start_sync: complete"

rescue => e
  puts "#{strava_id}: #{username}: start_sync: error occurred: #{e}"
end
