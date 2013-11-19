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

  puts
   
  $stops_file_text = ""
  
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
          
          #it was here
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
  
  
          #$stops_file_text += "{\"id\":\""+stop_id+"\"," "\"lon\":\""+stop_lon.to_s+"\","  "\"lat\":\""+stop_lat.to_s+"\"," \
          #"\"direction\":\""+stop_direction+"\"," "\"name\":\""+stop_name+"\"," "\"code\":\""+stop_code+"\"," "\"routes\":\""+$routes+"\"},"

        
        
        # case get just the stops detail info per each atomized stop
        #stop_file_text = "var stop  = "
        
        
        #stop_file_text += "{\"id\":\""+stop_id+"\"," "\"lon\":\""+stop_lon.to_s+"\","  "\"lat\":\""+stop_lat.to_s+"\"," \
        #"\"direction\":\""+stop_direction+"\"," "\"name\":\""+stop_name+"\"," "\"code\":\""+stop_code+"\"," "\"routes\":\""+$routes+"\"}"
       
        #puts stop_file_text
        #new google.maps.LatLng(37.772323, -122.214897),
        
        $stops_file_text += "new google.maps.LatLng("+stop_lat.to_s+", "+stop_lon.to_s+" ), \n"
        
        puts
       
                 
  end
  
  # case get just the stops for a given route
  route = $route_id.gsub(" ", "_")
  route = route.gsub("+", "plus")
  
  
  #put it here
 
  
  route_file_text = ""
  route_file_text += $stops_file_text
   


  puts route_file_text

  
  
end  