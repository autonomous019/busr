$LOAD_PATH << '.'

require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'
require 'yaml'


#PUT MASTER DATA SETTERS HERE
#need a list of stop objects per route_id via trip_id and stop_times
#create a master list of stops grouped by route
# p029dog.rb  
# define class Dog  
class Aggregator  
  def initialize(agency_name)  
    # Instance variables  
    @agency_name = agency_name 
    @agents = Array.new 
  end  
  
  
  
  #CLASS METHODS
  def agents()
      redis = Redis.new(:host => "localhost", :port => 6379) 
      agents = Array.new
      agents = redis.smembers('agencies')
      @agents = agents
      return agents
  end 
  
  
  
end 

#redis.sadd 'foo-tags', 'one'
agg = Aggregator.new('Intercity_Transit')
puts agg.agents() #sets agents array
puts agg.agents #@agents instance variable