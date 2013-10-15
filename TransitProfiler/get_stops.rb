require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'


redis = Redis.new(:timeout => 0)


#topObject = JSON.parse(File.read("event.json"));
topObject = JSON.parse(open("http://bustime.mta.info/api/where/stops-for-route/MTA%20NYCT_X17.json?key=3d264d9a-1aca-48b1-b375-929864bb5079").read)
#puts topObject
data = topObject["data"]
#puts data

stops = data["stops"]
#puts stops


stops.each do |s|
        stop_id = s["id"]
        puts stop_id
        stop_lon = s["lon"]
        puts stop_lon
        stop_lat = s["lat"]
        puts stop_lat
        stop_direction = s["direction"]
        puts stop_direction
        stop_name = s["name"]
        puts stop_name
        stop_code = s["code"]
        puts stop_code
        
        stop_routes = s["routes"]
        stop_routes.each do |r|
          route_id = r["id"]
          puts route_id
          route_shortName = r["shortName"]
          puts route_shortName
          route_longName = r["longName"]
          puts route_longName
          route_description = r["description"]
          puts route_description
          route_type = r["type"]
          puts route_type
          route_url = r["url"]
          puts route_url
          route_color = r["color"]
          puts route_color
          route_textColor = r["textcolor"]
          puts route_textColor
          route_agency = r["agency"]
          puts route_agency
          
        end
        
        puts "__________________"
end


puts redis.ping
redis.set('foo', 'bar')
puts redis.get('foo')


#end