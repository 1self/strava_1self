require 'sinatra'
require "sinatra/reloader"
require 'omniauth'
require 'omniauth-strava-oauth2'
require 'rest-client'
require 'time'

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
  userId = request.env['omniauth.auth']['uid']
  username = reques.env['omniauth.auth']['raw_info']['firstname']
  auth_token = request.env['omniauth.auth']['credentials']['token']

  puts "Env: #{request.env}"
  puts username
  puts auth_token
end
