var redis = require("redis"),
     client = redis.createClient();

client.on("error", function (err) {
    console.log("Error " + err);
});

var my_arr = new Array();
var stops = [ ];


//STOPS
exports.setStops = function(route_id, agency_name) {
	
    if(stops.length >= 1){
    	return stops;
    }

	var i = 0;
	
	
	
    client.llen(agency_name+'_stops_to_route_'+route_id, function(err,counted) {
	 
	   if (err) {
          
	  		my_arr += [{"stop_id":"404: error, no data"}];

	      } else {
			  console.log(counted);
			  i++;
			for(var i = 0, len = counted; i < len; i++) {  
		  	var k = 0;
		  		  client.lindex(agency_name+'_stops_to_route_'+route_id,i, function(err,results) {
			
		  			   if (err) {
		          
		  			  		my_arr += [{"stop_id":"404: error, no data"}];

		  			      } else {
							 
							 my_arr = results;
							 stops.push(my_arr);
				             //console.log(k);
							 //console.log(stops[k]);
							 
		  					 if(k === counted-1){
								 //console.log("------------");
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


