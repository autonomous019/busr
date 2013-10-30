require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'


redis = Redis.new()
#get routes from redis key "routes"
routes = redis["routes"]
route_atom = routes.split(" ")
route_atom.each do |a|
  
  
  #need to replace spaces in route with %20
 

  url = "http://bustime.mta.info/api/where/stops-for-route/"+a+".json?key=3d264d9a-1aca-48b1-b375-929864bb5079"
  #puts url
  topObject = JSON.parse(open(url).read)
  #puts topObject
  data = topObject["data"]
  #puts data

  stops = data["stops"]
  #puts stops
  stops.each do |s|
          stop_id = s["id"]
          #puts stop_id
          stop_lon = s["lon"]
          #puts stop_lon
          stop_lat = s["lat"]
          #puts stop_lat
          stop_direction = s["direction"]
          #puts stop_direction
          stop_name = s["name"]
          #puts stop_name
          stop_code = s["code"]
          #puts stop_code
        
        
        
          stop_routes = s["routes"]
          $routes = ""
          stop_routes.each do |r|
            
            route_id = r["id"]
            #route_id = route_id.gsub(/\s+/, "")
            $route_id = route_id
            $routes += route_id.gsub(" ", "%20")+" "
            #puts route_id
            route_shortName = r["shortName"]
            #puts route_shortName
            route_longName = r["longName"]
            #puts route_longName
            route_description = r["description"]
            #puts route_description
            route_type = r["type"]
            #puts route_type
            route_url = r["url"]
            #puts route_url
            route_color = r["color"]
            #puts route_color
            route_textColor = r["textcolor"]
            #puts route_textColor
            route_agency = r["agency"]
            #puts route_agency
          
          
          
          end
        
       
        
          #puts redis.sort('stops', :get => ['*->stop_id'])
          #puts redis.sort("stops", :by => "route|*->route_id", :get => "stops|*->stop_lat")
          #SORT mylist BY weight_*->fieldname GET object_*->fieldname  redis docs http://redis.io/commands/sort
        
          redis.hmset('stop_id:'+stop_id, 'stop_id', stop_id, 'stop_lon', stop_lon,  'stop_lat', stop_lat,  'stop_direction', stop_direction,  
          'stop_name', stop_name,  'stop_code', stop_code, 'routes', $routes   )
          redis.lpush('stops', 'stop_id:'+stop_id) 
          puts stop_id
          
        
        
  end
  
  
  
end  


=begin
#topObject = JSON.parse(File.read("event.json"));
topObject = JSON.parse(open("http://bustime.mta.info/api/where/stops-for-route/MTA%20NYCT_X17.json?key=3d264d9a-1aca-48b1-b375-929864bb5079").read)
#puts topObject
data = topObject["data"]
#puts data

stops = data["stops"]
#puts stops

=end


=begin
stops.each do |s|
        stop_id = s["id"]
        #puts stop_id
        stop_lon = s["lon"]
        #puts stop_lon
        stop_lat = s["lat"]
        #puts stop_lat
        stop_direction = s["direction"]
        #puts stop_direction
        stop_name = s["name"]
        #puts stop_name
        stop_code = s["code"]
        #puts stop_code
        
        
        
        stop_routes = s["routes"]
        stop_routes.each do |r|
          route_id = r["id"]
          route_id = route_id.gsub(/\s+/, "")
          $route_id = route_id
          puts route_id
          route_shortName = r["shortName"]
          #puts route_shortName
          route_longName = r["longName"]
          #puts route_longName
          route_description = r["description"]
          #puts route_description
          route_type = r["type"]
          #puts route_type
          route_url = r["url"]
          #puts route_url
          route_color = r["color"]
          #puts route_color
          route_textColor = r["textcolor"]
          #puts route_textColor
          route_agency = r["agency"]
          #puts route_agency
          
          
          
        end
        
       
        
        #puts redis.sort('stops', :get => ['*->stop_id'])
        #puts redis.sort("stops", :by => "route|*->route_id", :get => "stops|*->stop_lat")
        #SORT mylist BY weight_*->fieldname GET object_*->fieldname  redis docs http://redis.io/commands/sort
        
        redis.hmset('stop_id:'+stop_id, 'stop_id', stop_id, 'stop_lon', stop_lon,  'stop_lat', stop_lat,  'stop_direction', stop_direction,  
        'stop_name', stop_name,  'stop_code', stop_code, 'route_id', $route_id   )
        redis.lpush('stops', 'route:'+$route_id) 
        
        puts "__________________"
        
        
end

=end

#puts redis.ping
#redis.set('foo', 'bar')
#puts redis.get('foo')


#end