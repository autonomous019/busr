var redis = require("redis"),
     client = redis.createClient();

client.on("error", function (err) {
    console.log("Error " + err);
});

var my_arr = new Array();
var my_detail_arr = new Array();
var my_stops_arr = new Array();
var my_trip_stops_arr = new Array();
var stops = [ ];

var stops_info = [ ];
var stop_arr = [ ];

//trips
var trips = [ ];
var my_trips_arr = new Array();
var my_trips_detail_arr = new Array();


//In view get route_id then retrieve trips for route via trips.route_id then get stops from stop_times via stop_times.trip_id and stop_times.stop_id then get stop.lon and stop.lat to display on map.

//need to get stops for a trip_id set get from stop_times_<trip_id> where stops for a trip_id are part of the set

exports.setStops = function(route_id, agency_name, trips) {
    if(stops.length >= 1){
    	return stops;
    }
    //create a set based on each route and gather stops for that route and trips for the route
	
	trips.forEach(function(trip_id) {
		
		
		console.log(trip_id);
	  
		    var k = 0;
	
		    client.hgetall(trip_id, function(err, results) {
			
		       if (err) {
		          
		  		    my_arr += [{"stop_id":"404: error, no data"}];

		       } else {
				  
			   	    my_arr = results;
				    stops.push(my_arr);
				 
				    if(k == trips.length-1){
                    
					     return stops;
				    } 

		       }
			   k++;
		   });
 
       });

};


exports.getStops = function() {
	return stops;

};





//TRIPS TRIPS TRIPS 
exports.setTrips = function(route_id, agency_name) {
    if(trips.length >= 1){
    	return trips;
    }
    //create a set based on each route and gather stops for that route and trips for the route
	//$agency_id+"_trips_", route_id "Intercity_Transit_trips_13" [agencyname_trips_"route_id"]
    client.smembers(agency_name+'_trips_'+route_id, function(err, keys) {

    if (err) return console.log(err);
      //console.log("setTrips keys");
	 
	var stops_list = [ ]; 
	 
    for(var i = 0, len = keys.length; i < len; i++) {
		var k = 0;

		client.smembers(agency_name+'_stop_times_'+keys[i], function(err, results) {
			
		   if (err) {
		          
		  		my_trip_stops_arr += [{"stop_id":"404: error, no data"}];

		      } else {
				  console.log(results);
				 my_trip_stops_arr = results;
				 
				 stops_list.push(my_trip_stops_arr);
				 
				 if(k === keys.length-1){
	                 //console.log("______________");
					 //console.log(stops_list);
					
					 
					 //return trips;
				 } 

		     }
			 k++;
		});
    }
   });

};


exports.getTrips = function() {
	return trips;

};


/*
var s = stops_list;

for (var sl = 0; sl < s.length; sl++) {
 //console.log("A INDEX");
    //console.log(a[index]);
    //console.log(s[sl]);

 //console.log('get detail info for each stop in stops_list');
 //console.log(agency_name+":stop_"+s[sl]);
 

    var l = 0;

    client.hgetall(agency_name+":stop_"+s[sl], function(err, results) {

       if (err) {

  		    my_arr += [{"stop_id":"404: error, no data"}];

       } else {
		   console.log(results);
	   	    my_arr = results;
		    stops.push(my_arr);

		    if(l == stops.length-1){
				console.log("stops length");
				console.log(stops.length);
			     return stops;
		    } 

       }
	   l++;
   });

   }
*/


 
