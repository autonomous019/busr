require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'

#topObject = JSON.parse(File.read("event.json"));
topObject = JSON.parse(open("http://bustime.mta.info/api/where/routes-for-agency/MTA%20NYCT.json?key=3d264d9a-1aca-48b1-b375-929864bb5079").read)
#puts topObject
data = topObject["data"]
#puts data
references = data["references"]
#puts references
agencies = references["agencies"]
#puts agencies
=begin 
 from json feed: http://bustime.mta.info/api/where/routes-for-agency/MTA%20NYCT.json?key=3d264d9a-1aca-48b1-b375-929864bb5079
 
 {"id"=>"MTA NYCT_BX10", "textColor"=>"FFFFFF", "color"=>"006CB7", "description"=>"via Riverdale Av / W 231st St / Jerome Av", "longName"=>"Riverdale - Norwood", "shortName"=>"Bx10", "type"=>3, "agencyId"=>"MTA NYCT", "url"=>"http://www.mta.info/nyct/bus/schedule/bronx/bx010cur.pdf"}
 
 put into js array to display in node:
 var entries = [
 {"id":1, "title":"Hello World!", "body":"need to display agencies then routes for agency", "published":"6/2/2013"},
 {"id":2, "title":"Ride the N Line", "body":"please don't get stuck in the tunnel by Safeway!", "published":"6/3/2013"}];
=end
list = data["list"]
#puts list
puts "var routes = [ "
list.each do |l|
        route_id = l["id"]
        textColor = l["textColor"]
        color = l["color"]
        description = l["description"]
        longName = l["longName"]
        shortName = l["shortName"]
        type = l["type"]
        agencyId = l["agencyId"]
        url = l["url"]
        
        puts "{\"id\":\""+route_id+"\","
        puts "\"textColor\":\""+textColor+"\","
        puts "\"color\":\""+color+"\","
        puts "\"description\":\""+description+"\","
        puts "\"longName\":\""+longName+"\","
        puts "\"shortName\":\""+shortName+"\","
        puts "\"type\":\""+type.to_s+"\","
        puts "\"agencyId\":\""+agencyId+"\","
        puts "\"url\":\""+url+"\"},"
       
end
puts "];"



#sections = topObject ["sections"]
#sections.each do |section|
    
#    puts section
    #section_id = section["section_id"]
    #      events = section["events"]
    #      events.each do |event|
    #            event_id = event["event_id"]
    #            event_name = event["event_name"]
    #            puts event_name
    #       end
#end