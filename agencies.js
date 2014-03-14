var redis = require("redis"),
     client = redis.createClient();

client.on("error", function (err) {
    console.log("Error " + err);
});

var my_arr = new Array();
var my_detail_arr = new Array();
var agencies = [ ];
var agent_info = [ ];
var agent = [ ];

exports.getAgencies = function(req, res) {
    if(agencies.length >= 1){
    	agencies = [];
    }

    client.smembers('agencies', function(err, keys) {

    if (err) return console.log(err);
  
    for(var i = 0, len = keys.length; i < len; i++) {
		var k = 0;
		keys[i] = "agency:"+keys[i];
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

 exports.getAgency = function(agency_name) {
     if(agent.length >= 1){
     	agent = [];
     }
	 client.hgetall("agency:"+agency_name, function(err, results) {
		
	   if (err) {
	          
	  		agent = [{"agency_name":"404: error, no data", "agency_id":"sorry, temporary error"}];
            return results;
	      } else {
			  
			 my_detail_arr = results;
			 agent.push(my_detail_arr);
			 console.log(agent);
			 return agent;

	      }
		  k++;
	});
 }
 
 exports.getAgencyStatic = function() {
 	return agent;
 }

 
