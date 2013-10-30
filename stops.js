var redis = require("redis");
var client = redis.createClient();

/*
var stops = [ 
{"id":"MTA NYCT_BX10",
"textColor":"FFFFFF",
"color":"006CB7",
"description":"via Riverdale Av / W 231st St / Jerome Av",
"longName":"Riverdale - Norwood",
"shortName":"Bx10",
"type":"3",
"agencyId":"MTA NYCT",
"url":"http://www.mta.info/nyct/bus/schedule/bronx/bx010cur.pdf"}
]



{ stop_id: 'MTA_405393',
  stop_lon: '-73.98307',
  stop_lat: '40.766285',
  stop_direction: 'NE',
  stop_name: '8 AV/W  56 ST',
  stop_code: '405393',
  route_id: 'MTA NYCT_M104' }

*/



client.on("error", function (err) {
    console.log("Error " + err);
});

//client.set("string key", "string val", redis.print);
//client.hset("hash key", "hashtest 1", "some value", redis.print);
//client.hset(["hash key", "hashtest 2", "some other value"], redis.print);
/*
client.hkeys("stop_id:MTA_405393", function (err, replies) {
    console.log(replies.length + " replies:");
    replies.forEach(function (reply, i) {
        console.log("    " + i + ": " + reply);
    });
    client.quit();
});
*/


client.hgetall("stop_id:MTA_200392", function (err, obj) {
    
    console.dir(obj.stop_code);
});
client.quit();