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

# Defaults to strict checking of required columns
#source = GTFS::Source.build("http://gtfs.s3.amazonaws.com/santa-cruz-metro_20130918_0104.zip")

# Relax the column checks, useful for sources that don't conform to standard
#source = GTFS::Source.build("http://gtfs.s3.amazonaws.com/santa-cruz-metro_20130918_0104.zip", {strict: false})


#writing to redis db is handled in gtfs/model.rb parse_model method
redis = Redis.new()
#parse json in js    var json = '{"result":true,"count":1}', obj = JSON && JSON.parse(json) || $.parseJSON(json);


agency_uri = Array.new
agency_uri << 'files/intercity-transit_20140107_0555.zip' #olympia
#agency_uri << 'files/humboldt-archiver_20140107_0650.zip' #eureka/arcata
#agency_uri << 'files/mts_20140208_0134.zip' #san diego
#agency_uri << 'http://www.intercitytransit.com/googledata/google_transit.zip'
#agency_uri << 'http://gtfs.s3.amazonaws.com/santa-cruz-metro_20130918_0104.zip'


agency_uri.each do |au|
  #puts
  puts "#{au}"
  source = GTFS::Source.build(au)
  agencies = source.agencies #REQUIRED TO RUN if you just are going for one particular file model you need model file plus agencies
  routes = source.routes
  stops = source.stops
  #trips =source.trips
  #stop_times = source.stop_times 
  #source.calendars  
  #source.calendar_dates     
  #source.fare_attributes   
  #source.fare_rules         
  #source.frequencies  #debug only headers in txt file no data need to confirm it works     
  #source.transfers 
  #source.shapes
  
end