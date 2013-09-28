var entries = [
{"id":1, "title":"Hello World!", "body":"need to display agencies then routes for agency", "published":"6/2/2013"},
{"id":2, "title":"Ride the N Line", "body":"please don't get stuck in the tunnel by Safeway!", "published":"6/3/2013"}];

/*
var routes = [
              {"id":"MTA NYCT_BX10",
              "textColor":"FFFFFF",
              "color":"006CB7",
              "description":"via Riverdale Av / W 231st St / Jerome Av",
              "longName":"Riverdale - Norwood",
              "shortName":"Bx10",
              "type":"3",
              "agencyId":"MTA NYCT",
              "url":"http://www.mta.info/nyct/bus/schedule/bronx/bx010cur.pdf"},
              {"id":"MTA NYCT_BX11",
              "textColor":"FFFFFF",
              "color":"FAA61A",
              "description":"via Claremont Pkwy / E 170th St",
              "longName":"West Farms Rd - Southern Blvd & GW Bridge",
              "shortName":"Bx11",
              "type":"3",
              "agencyId":"MTA NYCT",
              "url":"http://www.mta.info/nyct/bus/schedule/bronx/bx011cur.pdf"}
              ];
*/

exports.getBusrEntries = function() {
	return entries;
}

exports.getBusrRoutes = function() {
	return routes;
}

exports.getBusrRoute = function(id) {
	for(var i=0; i<routes.length; i++) {
		if(routes[i].id == id) return routes[i];
	}
}