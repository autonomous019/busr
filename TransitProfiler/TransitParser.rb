#!/usr/bin/ruby

require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'

#this class is the highest level of the TransitProfiling system and all other classes shall inherit it. 
 
class TransitParser
  @@number_of_agencies=1  #update this when more are added. 
    #####################################initialize()########################
    def initialize(agency, spec_format)
      @routes = Hash.new(0)
      @agencies = [ "NYC MTA", "Chicago", "London", "Los Angeles", "Seattle", ]
      @agency = agency 
      @redis =  Redis.new()  #nosql key/value store using redis, get routes from it
      @spec_format = spec_format #such as SIRI, GTFS, etc. will need to create a format mapper for each unique spec to parse data
    end

    #####################################getTopObject()########################
    #gets the highest element in the json call which is a container for all other elements
    def getRouteTopObject(url)
      topObject = JSON.parse(open(url).read)
      return topObject
      
    end  
    
    #####################################getTopObject()########################
    #pass in url of json feed 
    def getRouteData(url)
      topObject = getRouteTopObject(url)
      data = topObject["data"]
      return data
    end
end #ends class 