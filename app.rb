require 'rubygems'
require 'sinatra'
require 'tropo-webapi-ruby'
require 'httparty'
require 'logger'
require 'net/http'
require 'uri'


use Rack::Session::Pool





get '/' do
  "Hello World"
end

post '/start.json' do
  tropo_session = Tropo::Generator.parse request.env["rack.input"].read
  session[:callid] = tropo_session[:session][:id]
  session[:truck_name] = 'not found'

  tropo = Tropo::Generator.new do
    ask( :name => 'truck', :bargein => true, :timeout => 60, :attempts => 2,
          :say => [{:event => "timeout", :value => "Sorry, I did not hear anything."},
                   {:event => "nomatch:1 nomatch:2", :value => "Oops, I don't recognize that food truck'."},
                   {:value => "Which food truck do you want?"}],
                    :choices => { :value => "ken-jeez, calvins, gordmelt"})
    on :event=>'continue', :next => "/process_truck.json"

  end

  tropo.response
end

post '/hangup.json' do
  say "Thanks for nomming."
end

post '/the_answer.json' do
  say "Test Answer"
end

post '/process_truck.json' do
  tropo_session = Tropo::Generator.parse request.env["rack.input"].read

  truck = tropo_session[:result][:actions][:truck][:value]

  puts "Chosen truck: " + truck

  tropo = Tropo::Generator.new do
    say "You chose " + truck
    if truck == "ken-jeez" then
      foodtruckId = "4e4b3ef6aeb72792c3381b27"
      puts "KENJI Routing..."
      urlToGo = "http://api.foursquare.com/v2/venues/" +foodtruckId + "?client_id=" + ENV['FOURSQUARE_CLIENT_ID'] + "&client_secret=" + ENV['FOURSQUARE_CLIENT_SECRET']
      puts "URLTOGO: " + urlToGo
      foursquareInfo = JSON.parse(open(urlToGo).read)
      puts "FOURSQUAREINFO: " + foursquareInfo
    end
  end

  tropo.response
end