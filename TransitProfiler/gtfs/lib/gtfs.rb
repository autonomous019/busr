$LOAD_PATH << '.'

require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'
require 'yaml'

require 'gtfs/version'
require 'gtfs/model'
require 'gtfs/agency'
require 'gtfs/calendar'
require 'gtfs/calendar_date'
require 'gtfs/route'
require 'gtfs/shape'
require 'gtfs/stop'
require 'gtfs/stop_time'
require 'gtfs/trip'
require 'gtfs/custom_exceptions'
require 'gtfs/fare_attribute'
require 'gtfs/fare_rule'
require 'gtfs/frequency'
require 'gtfs/transfer'

require 'gtfs/source'
require 'gtfs/url_source'
require 'gtfs/local_source'

#writing to redis db is handled in gtfs/model.rb parse_model method
redis = Redis.new()

agency_uri = Array.new
agency_uri << 'http://www.intercitytransit.com/googledata/google_transit.zip'
agency_uri << 'http://gtfs.s3.amazonaws.com/santa-cruz-metro_20130918_0104.zip'


agency_uri.each do |au|
  puts "#{au}"
  source = GTFS::Source.build(au)

 agencies = source.agencies
  
  #p source.instance_variables
  #p source.files
  #p source.agencies.inspect
  #p YAML::dump(source)
  
  #puts
  #arr = source.agencies.to_s
  #arr_copy = arr.split(",").map(&:to_s)
  #puts arr_copy.length
  
  
  #redis stuff to write stops to hashes
    #redis.hmset('stop_id:'+stop_id, 'stop_id', stop_id, 'stop_lon', stop_lon,  'stop_lat', stop_lat,  'stop_direction', stop_direction,  
    #'stop_name', stop_name,  'stop_code', stop_code, 'routes', $routes   )
    #redis.lpush('stops', 'stop_id:'+stop_id) 
  
  
  
end
=begin

# Defaults to strict checking of required columns
source = GTFS::Source.build("http://gtfs.s3.amazonaws.com/santa-cruz-metro_20130918_0104.zip")

# Relax the column checks, useful for sources that don't conform to standard
#source = GTFS::Source.build("http://gtfs.s3.amazonaws.com/santa-cruz-metro_20130918_0104.zip", {strict: false})

#http://www.intercitytransit.com/googledata/google_transit.zip 
#http://www.gtfs-data-exchange.com/agency/santa-cruz-metro/latest.zip
#http://gtfs.s3.amazonaws.com/ac-transit_20130625_0854.zip

#TODO
#account for missing fields in each file model.  

p source.agencies
p source.instance_variables
p source.files

#a = GTFS::Agency()
#a.instance_variables

puts
arr = source.agencies.to_s
arr_copy = arr.split(",").map(&:to_s)
puts arr_copy.length

#p source.stops

#source.each_agency {|agency| puts agency}

=end



