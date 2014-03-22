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
  
  
  
  #CLASS METHODS
  
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
      #get trips for a route
      trips = @redis.smembers(@agency_name+"_trips_"+route_id)
      #stops here are trips 
      trips.each do |t|
       
        $stop = Hash.new
        temp_stops = @redis.smembers(@agency_name+"_stop_times_"+t)
        temp_stops.each do |ts|
          puts ts
          @redis.sadd(@agency_name+"_stops_to_trip_"+t.to_s, ts) #list of trips 
          
        end
        puts "-------"
        puts @agency_name+"_stops_to_trip_"+t.to_s
        puts @redis.smembers(@agency_name+"_stops_to_trip_"+t.to_s)
        #trips.push(@redis.smembers(@agency_name+"_stop_times_"+t).to_s)
      end
      #create a list for stops by trips
      #create a list with only unique values of stops per route for map display
      puts "LEN "+trips.length.to_s
      
      stops.each do |s|
        @redis.sadd(@agency_name+'trips_to_'+route_id+'_'+t)
        
      end
      return stops
  end 
  
  
end 

#redis.sadd 'foo-tags', 'one'
agg = Aggregator.new('Intercity_Transit')
puts agg.agents() #sets agents array
puts agg.agents #@agents instance variable
agg.stops('7')