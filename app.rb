require 'rubygems'
require 'sinatra'
require 'tropo-webapi-ruby'

get '/' do
  "Hello World"
end

post '/start.json' do
  p Tropo::Generator.parse request.env['rack.input'].read
end