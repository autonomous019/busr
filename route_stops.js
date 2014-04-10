var redis = require("redis"),
     client = redis.createClient();

client.on("error", function (err) {
    console.log("Error " + err);
});



var my_arr = new Array();
var stops =  new Array();

var my_route_arr = new Array();
var route_maps =  new Array();
var shape_keys =  new Array();

//STOPS
exports.setStops = function(route_id, agency_name) {
	
    if(stops.length >= 1){
    	 stops.length = 0;
    }

	var i = 0;	
	//smembers(@agency_name+"_stops_to_route_"+route_id)  
    client.smembers(agency_name+'_stops_to_route_'+route_id, function(err,stop_ids) {
	
	console.log(agency_name+'_stops_to_route_'+route_id+' '+stop_ids+' '+i);
	
	   if (err) {
          
	  		my_arr += [{"stop_id":"404: error, no data"}];

	      } else {
			  
			  i++;
			  for(var i = 0, len = stop_ids.length; i < len; i++) {  
		  	      var k = 0;
	
				  
				  //"Intercity_Transit:stop_82"
		  		client.hgetall(agency_name+':stop_'+stop_ids[i], function(err, results) {
			
		  		   if (err) {
		          
		  		  		my_arr += [{"agency_id":"404: error, no data", "agency_url":"sorry, temporary error"}];

		  		      } else {
				  
		  				 my_arr = results;
		  				 stops.push(my_arr);
				 
		  				 if(k == stop_ids.length-1){
		  					 //console.log(stops);
		  					 return stops;
		  				 } 

		  		     }
		  			  k++;
		  		});
				  
				  
		  		
	     }
	  }
	});	

};
exports.getStops = function(route_id, agency_name) {
	this.setStops(route_id, agency_name);
	
	return stops;

};



exports.setRouteMap = function(route_id, agency_name) {
	
    if(route_maps.length >= 1){
    	 route_maps.length = 0;
    }

	var i = 0;	 
    client.smembers(agency_name+'_route_shapes_'+route_id, function(err,route_map_ids) {
		
	   if (err) {
          
	  		my_route_arr += [{"route_map_id":"404: error, no data"}];

	      } else {
			  
			  i++;
			  for(var i = 0, len = route_map_ids.length; i < len; i++) {  
		  	      var k = 0;
	
				  //console.log(route_map_ids[i]);
				  var route_params = route_map_ids[i].split(" ");
				  var shape_id = route_params[0];
				  var shape_sequence = route_params[1];
				  shape_keys.push(shape_id+'_'+shape_sequence);
				  
				//redis-cli hgetall 'Intercity_Transit:shapes_8_17'
		  		client.hgetall(agency_name+':shapes_'+shape_id+'_'+shape_sequence, function(err, results) {
			
		  		   if (err) {
		          
		  		  		my_route_arr += [{"agency_id":"404: error, no data", "agency_url":"sorry, temporary error"}];

		  		      } else {
				  
		  				 my_route_arr = results;
		  				 route_maps.push(my_route_arr);
				 
		  				 if(k == route_map_ids.length-1){
							 route_maps = route_maps.sort();
		  					 console.log(route_maps);
		  					 return route_maps;
		  				 } 

		  		     }
		  			  k++;
		  		});
				  
				  
		  		
	     }
	  }
	});	

};
exports.getRouteMap = function(route_id, agency_name) {
	this.setRouteMap(route_id, agency_name);
	route_maps = route_maps.sort();
	return route_maps;

};


//redis-cli smembers 'Intercity_Transit_route_shapes_8'
