require 'sinatra'
require "sinatra/reloader"
require 'omniauth'
require 'omniauth-strava-oauth2'
require 'pg'

require_relative 'defaults'
require_relative 'lib/Oneself'

get '/' do
  "There's nothing here."
end

get '/login' do
  session['oneselfUsername'] = params[:username]
  session['registrationToken'] = params[:token]
  puts "Redirecting #{params[:username]} to login."

  redirect to("/auth/strava")
end

get '/auth/strava/callback' do
  instagram_user_id = request.env['omniauth.auth']['uid']
  username = request.env['omniauth.auth']['info']['firstname']
  auth_token = request.env['omniauth.auth']['credentials']['token']

  conn = PG::Connection.open(:dbname => 'dev')
  conn.exec_params('INSERT INTO USERS (name, instagram_id, access_token) VALUES ($1, $2, $3)', [username, instagram_user_id, auth_token])
  
  stream = Oneself::Stream.register(session['oneselfUsername'],
                                    session['registrationToken'],
                                    instagram_user_id
                                    )

  sync(username, auth_token, stream)

  redirect(Defaults::ONESELF_API_HOST + '/integrations')
end


def sync(uname, auth_token, stream)
  sync_start_event = Oneself::Event.sync("start")
  Oneself::Event.send(sync_start_event)

  strava_helper = StravaHelper.new(auth_token)

  ride_events = strava_helper.get_events("Ride")
  run_events = strava_helper.get_events("Run")
  sync_end_event = Oneself::Event.sync("complete")

  all_events = ride_events + 
    run_events + sync_end_event

  Oneself::Event.send(all_events)

  puts "Sync complete"
end
