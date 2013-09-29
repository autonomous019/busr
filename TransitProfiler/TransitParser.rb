require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'

 
class TransitParser
    #####################################initialize()########################
    def initialize()
      @routes = Hash.new(0)
    end
		

    #####################################getTopObject()########################
    #gets the highest element in the json call which is a container for all other elements
    def getTopObject(url)
      topObject = JSON.parse(open(url).read)
      return topObject
      
    end  
end #ends class 

 
#now run the program
a = TransitParser.new()

a.printer 