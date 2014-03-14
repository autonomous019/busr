var redis = require("redis"),
     client = redis.createClient();

client.on("error", function (err) {
    console.log("Error " + err);
});

var my_arr = new Array()
var agencies = [ ]

exports.getAgencies = function(req, res) {
    if(agencies.length >= 1){
    	agencies = [];
    }
	//how to return keys by wildcard 
    client.keys('*', function(err, keys) {

    if (err) return console.log(err);
  
    for(var i = 0, len = keys.length; i < len; i++) {
		var k = 0;
		client.hgetall(keys[i], function(err, results) {
			
		   if (err) {
		          
		  		my_arr += [{"agency_id":"404: error, no data", "agency_url":"sorry, temporary error"}];

		      } else {
				 my_arr = results;
				 agencies.push(my_arr);
				 
				 if(k == keys.length-1){
                    
					 return agencies;
				 } 

		      }
			  k++;
		});
    }
   });

};



 

 exports.getAgenciesStatic = function() {
 	return agencies;
 }

 exports.getAgency = function(id) {
 	for(var i=0; i<agencies.length; i++) {
 		if(agencies[i].id == id) return agencies[i];
 	}
 }