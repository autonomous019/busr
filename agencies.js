var redis = require("redis"),
     client = redis.createClient();

 client.on("error", function (err) {
     console.log("Error " + err);
 });

var agencies = [];
var my_list = new Array();
var temp_arr = new Array();
var my_arr = new Array()

function Gatherer(agency) {
  this.agency = agency;
  this.data = ['']; 
  //console.log(this.agency);
};

Gatherer.prototype.showData = function () { console.log(this.name, this.data); };

Gatherer.prototype.setData = function() {
	
	client.hgetall(this.agency, function(err, results) {
		 
	   if (err) {
	          // do something like callback(err) or whatever
	  		my_arr += [{"agency_id":"404", "agency_url":"sorry, temporary error"}];
	
	      } else {
			 //console.log(results);
	  	     my_arr = results;
	  	     my_arr = JSON.stringify(results);
	  	     my_arr = JSON.parse(my_arr);
			 this.data += my_arr;
			 //console.log(this.data)
	 
	      }
	   });
	   
	   return this.data;
};




client.keys('*', function (err, keys) {
  if (err) return console.log(err);
  
  for(var i = 0, len = keys.length; i < len; i++) {
	  
	  var gatherer1 = new Gatherer(keys[i]);
	  gatherer1.setData();
	  agencies += gatherer1.data;
	  //console.log(agencies);
	  
	 
  }
});



exports.getAgencies = function(req, res) {
	console.log("getAgencies");
	
    var return_dataset = [];
    client.keys('*', function(err, keys) {
		
    if (err) return console.log(err);
  
    for(var i = 0, len = keys.length; i < len; i++) {
	  
       
 
		client.hgetall(keys[i], function(err, results) {
			
		   if (err) {
		          // do something like callback(err) or whatever
		  		my_arr += [{"agency_id":"404", "agency_url":"sorry, temporary error"}];
	
		      } else {
				 console.log(results);
		  	     my_arr = results;
		  	     my_arr = JSON.stringify(results);
		  	     my_arr = JSON.parse(my_arr);
				 //this.data += my_arr;
				 //console.log(my_arr);
				 //return_dataset += my_arr;
				 
				 return_dataset.push(results);
				 
				 if(i == len+1){
					 
					 //return_dataset.push(results);
				 	 console.log(return_dataset);
					 return return_dataset;
				 }
				 
	             
		      }
		   });
	   
	  
	 
  }
  //console.log(return_dataset);
  //return return_dataset;
 

 
  });
	
	
	
};





//console.log("final array \n");
//console.log(agencies);
//console.log(my_list);
//console.log(temp_arr);

//foo1.showData();






 

// exports.getAgencies = function() {
// 	return agencies;
// }

 exports.getAgency = function(id) {
 	for(var i=0; i<agencies.length; i++) {
 		if(agencies[i].id == id) return agencies[i];
 	}
 }