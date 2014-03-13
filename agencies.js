var redis = require("redis"),
     client = redis.createClient();

 client.on("error", function (err) {
     console.log("Error " + err);
 });


var my_list = new Array();
var temp_arr = new Array();
var my_arr = new Array()



var agencies = [ 
  

	]

exports.getAgencies = function(req, res) {


    //var agencies = [];
    client.keys('*', function(err, keys) {

    if (err) return console.log(err);
  
    for(var i = 0, len = keys.length; i < len; i++) {
		var k = 0;
		client.hgetall(keys[i], function(err, results) {
			
		   if (err) {
		          // do something like callback(err) or whatever
		  		my_arr += [{"agency_id":"404", "agency_url":"sorry, temporary error"}];

		      } else {
				 my_arr = results;
		  	     //my_arr = JSON.stringify(results);
		  	     //my_arr = JSON.parse(my_arr);


				 agencies.push(my_arr);
				 //agencies += my_arr; //array of objects
                 
				 if(k == keys.length-1){
                     //console.log("********");
				 	 //console.log(agencies);
					 //console.log("********");
					 
					 return agencies;
				 } 


		      }
			  k++;
		   });

    }

 
  });

//return agencies;

};



 

 exports.getAgenciesStatic = function() {
 	return agencies;
 }

 exports.getAgency = function(id) {
 	for(var i=0; i<agencies.length; i++) {
 		if(agencies[i].id == id) return agencies[i];
 	}
 }