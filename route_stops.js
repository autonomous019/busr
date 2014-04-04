var redis = require("redis"),
     client = redis.createClient();

client.on("error", function (err) {
    console.log("Error " + err);
});



var my_arr = new Array();
var stops =  new Array();

//STOPS
exports.setStops = function(route_id, agency_name) {
	
    if(stops.length >= 1){
    	return stops;
    }

	var i = 0;	
	//smembers(@agency_name+"_stops_to_route_"+route_id)  
    client.smembers(agency_name+'_stops_to_route_'+route_id, function(err,stop_ids) {
	console.log(stop_ids);
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
		  					 console.log(stops);
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


