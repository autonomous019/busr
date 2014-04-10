$LOAD_PATH << '.'

require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'
require 'yaml'
require 'optparse'



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
      #puts route_id
      #get trips for a route
      trips = @redis.smembers(@agency_name+"_trips_"+route_id)
      #puts trips.length.to_s
      
      trips.each do |t|      
        $stop = Hash.new
        temp_stops += @redis.smembers(@agency_name+"_stop_times_"+t)
      end
      
      #create a uniq list of stops by stop_id and push detail info into stop_info array
      temp_stops = temp_stops.uniq
      
      #puts @agency_name+"_stops_to_route_"+route_id
      temp_stops.each do |ts|
        #puts ts
        @redis.SADD(@agency_name+"_stops_to_route_"+route_id, ts.to_s)
      end
      #puts @redis.smembers(@agency_name+"_stops_to_route_"+route_id)  
      
      
     return temp_stops
  end 
  
  

  
  ########### route_map() #################################################### 
  
 
  def route_map(route_id)
      coords = Array.new
      temp_coords = Array.new
      trips = Array.new
      shape_ids = Array.new
      shapes = Array.new
      
      #get trips for a route
      trips = @redis.smembers(@agency_name+"_trips_"+route_id.to_s)
      trips.each do |t|      
        
        #hmget 'Intercity_Transit:trip_380' shape_id
        shape_ids += @redis.hmget(@agency_name+":trip_"+t, "shape_id")
      end
      shape_ids.each do |sid|
        #redis-cli smembers 'Intercity_Transit_shape_8'
        shapes = @redis.smembers(@agency_name+"_shape_"+sid.to_s)
        shapes.each do |s|
          #redis-cli hgetall 'Intercity_Transit:shapes_8_17'
          coords.push(@redis.hgetall(@agency_name+":shapes_"+sid.to_s+"_"+s.to_s))
          @redis.SADD(@agency_name+"_route_shapes_"+route_id.to_s, sid.to_s+" "+s.to_s)
          #creates redis set redis-cli smembers 'Intercity_Transit_route_shapes_8' which is picked up in route_stops.js
        end  
      end
      temp_coords = coords.uniq
      puts temp_coords.length
      temp_coords.each do |c|
        puts c
        
      end
     
      
     return temp_coords
  end
  
  
end 


# main driver
options = {}
OptionParser.new do |opts|
  
  opts.banner = "Usage: aggregator.rb [options]"

  
  opts.on("-a", "--agency", "transit agency") do |a|
    #puts "agency: "+a.to_s
    options[:agency] = a
  end
  
  #need an option -l to list agencies ready for aggregation
  
  
end.parse!

#puts options
#puts ARGV

#TODO: create a list of stops that service multiple routes and list as transfer stops

ARGV.each do |argv|
  agg = Aggregator.new(argv)
  puts "Aggregating Data into Redis for Agency: "+argv
  redis = Redis.new(:host => "localhost", :port => 6379) 
  
  
  agg.route_map(8)
  exit()
  
  
  #get set of routes for each agency 
  routes = redis.smembers(argv+'_routes') 
  
  #keep the agencies atomized for testing purposes until the system is robust enough. 
  #puts agg.agents() #sets agents array
  #puts agg.agents #@agents instance variable

  #get a list of routes by agency, then generate stops for routes
  routes.each do |r|
    agg_stops = agg.stops(r)
    puts "Route: "+ r+" STOPS LEN "+agg_stops.length.to_s
  end
end
puts "---------------------------------------------"
puts


=begin
Route Line Drawing Algorithm:
get a list of all trips for a route by route_id i.e. 8
$ redis-cli smembers 'Intercity_Transit_trips_8'



get the shape_id for trip 380 
$ redis-cli hmget 'Intercity_Transit:trip_380' shape_id

Intercity_Transit_shape_8 a set of all shape_sequences by shape_id
redis-cli smembers 'Intercity_Transit_shape_8'

and finally get and add to map:
$ redis-cli hgetall 'Intercity_Transit:shapes_8_17'
 1) "shape_id"
 2) "8"
 3) "shape_pt_sequence"
 4) "17"
 5) "shape_dist_traveled"
 6) "1.71212244884"
 7) "shape_pt_lat"
 8) "47.03907"
 9) "shape_pt_lon"
10) "-122.91466"
=end


