

	var redis = require("redis");
	var client = redis.createClient();

	client.on("error", function (err) {
	    console.log("Error " + err);
	});

	
	var stop = [];
	
	/*var stop = 
	{ id: 'MTA_200392',
  lon: '-74.167397',
  lat: '40.589016',
  direction: 'NE',
  name: 'RICHMOND AV/RICHMOND HILL RD',
  code: '200392',
  routes: 'MTA%20NYCT_S44 MTA%20NYCT_S59 MTA%20NYCT_S89 MTA%20NYCT_S94 MTA%20NYCT_X17 MTA%20NYCT_X17A ' }
  */
	
  function createData(id){
      client.hgetall("stop_id:"+id, function (err, obj) {
        //var _stop = [];
          stops =  
             {
  	        "id":""+obj.stop_id+"",
  	        "lon": ""+obj.stop_lon+"",
  	        "lat": ""+obj.stop_lat+"",
  	        "direction": ""+obj.stop_direction+"",
  	        "name": ""+obj.stop_name+"",
  	        "code": ""+obj.stop_code+"",
  	        "routes": ""+obj.routes+""
          }
		    
  	  var data = stops;
	  stop = data;
	  //console.log(stop);
	  
	  return stop;
	 
    });
}


// Parses the specified text.
exports.getStop = function(id) {
	
	var stop = createData(id);
	
    setTimeout(function () {
      // console.log(stop);
       
     }, 3000);
	
	
	
	return stop;

}
//module.exports.getStop;
