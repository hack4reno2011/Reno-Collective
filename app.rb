require 'rubygems'
require 'sinatra'
require 'tropo-webapi-ruby'

enable :sessions

get '/' do
  "Hello World"
end

post '/start.json' do
  tropo_session = Tropo::Generator.parse request.env["rack.input"].read
  session[:callid] = tropo_session[:session][:id]
  tropo = Tropo::Generator.new do
    say :value => 'Hello World!'
    on :event => 'hangup', :next => '/hangup.json'
  end
  tropo.response
end

post '/hangup.json' do
  tropo_event = Tropo::Generator.parse request.env["rack.input"].read
  p tropo_event
end