$LOAD_PATH << '.'

require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'
require 'yaml'


#PUT MASTER DATA SETTERS HERE
#need a list of stop objects per route_id via trip_id and stop_times
#create a master list of stops grouped by route

#Aggregator does heavy lifting of crunching data and setting up final object lists for views (i.e. collections based on models) Basic data is gathered in model.rb when it is called by gtfs.rb this class aggregates those data structs
class Aggregator  
  
  def initialize(agency_name)  
    # Instance variables  
    @agency_name = agency_name 
    @agents = Array.new 
    @redis = Redis.new(:host => "localhost", :port => 6379) 
  end  

  
  ########### agents() #################################################### 
  #create a list of agents in the system
  def agents()  
      agents = Array.new
      agents = @redis.smembers('agencies')
      @agents = agents
      return agents
  end 
  
  
 
  ########### stops() #################################################### 
  #need a list of stop objects per route_id via trip_id and stop_times
  #create a master list of stops grouped by route
  #get Intercity_Transit_trips to get all trips for a route then get all stops from ‘Intercity_Transit_stop_times_<trip_id>’
  #redis-cli SMEMBERS 'Intercity_Transit_trips_7’ gets all trips for a route as INT by trip_id
 
  def stops(route_id)
      stops = Array.new
      trips = Array.new
      temp_stops = Array.new
     
      #get trips for a route
      trips = @redis.smembers(@agency_name+"_trips_"+route_id)
 
      trips.each do |t|      
        $stop = Hash.new
        temp_stops += @redis.smembers(@agency_name+"_stop_times_"+t)
      end
      
      #create a uniq list of stops by stop_id and push detail info into stop_info array
      temp_stops = temp_stops.uniq
     
      puts @agency_name+"_stops_to_route_"+route_id
      temp_stops.each do |ts|
        @redis.SADD(@agency_name+"_stops_to_route_"+route_id, ts.to_s)
      end
      puts @redis.smembers(@agency_name+"_stops_to_route_"+route_id)  
      
      
     return temp_stops
  end 
  
  
end 

#redis.sadd 'foo-tags', 'one'
agg = Aggregator.new('Intercity_Transit')
puts agg.agents() #sets agents array
puts agg.agents #@agents instance variable

#get a list of routes by agency, then generate stops for routes
agg_stops = agg.stops('13')
puts "STOPS LEN "+agg_stops.length.to_s
