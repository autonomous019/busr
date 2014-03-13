var express = require('express');
var app = express();
/*
app
  .use(express.bodyParser())
  .use(express.cookieParser('busrinf0!!!'))
  .use(express.session())
  .use(everyauth.middleware(app));
*/
  
var hbs = require('hbs');
//var everyauth = require('everyauth');


var routesEngine = require('./routes');
var agenciesEngine = require('./agencies');
var busrEngine = require('./busr');
var posterEngine = require('./poster');



app.set('view engine', 'html');
app.engine('html', hbs.__express);
app.use(express.bodyParser());

app.use(express.static('public'));

app.get('/', function(req, res) {
	res.render('index',{title:"Busr Transitor", entries:busrEngine.getBusrEntries()});
});



//ROUTES ROUTES ROUTES <as in bus routes not app routing>
app.get('/routes', function(req, res) {
	res.render('routes',{title:"MTA Routes", routes:routesEngine.getRoutes()});
});

app.get('/route/:id', function(req, res) {
	var route_id = req.params.id;
	route_id = route_id.replace("%20","_");
	route_id = route_id.replace(" ", "_");
	route_id = route_id.replace("+", "plus");
	var stops_data = require('./cache/route_stops_'+route_id+'.js');
	//get based on js var route_id
	var stops = stops_data.getStops(route_id);
	var route = routesEngine.getRoute(req.params.id);
	res.render('route',{id:route.id, route:route, stops:stops});
});





//STOPS STOPS STOPS
app.get('/stops/:id', function(req, res) {
	var route_id = req.params.id;
	var stops_data = require('./cache/route_'+route_id+'.js');
	//get based on js var route_id
	var stops = stops_data.getStops(route_id);
	res.render('stops',{id:stops.id, stops:stops});
});

app.get('/stop/:id', function(req, res) {
	var stop_data = require('./cache/stop_'+req.params.id+'.js');
	//console.log(stop_data);
    //var stopsEngine = require('./stops');
	var stop = stop_data.getStop(req.params.id);
	console.log(req.params.id);
	console.log(stop);
	res.render('stop',{id:stop.id, stop:stop});
});

app.get('/map', function(req, res) {
	//var map_points = require('./maps/icon.js');
	res.render('map', {title:"Map"});
});


//Trip Planning
app.post('/tripresult', function(req, res){ // Specifies which URL to listen for
  // req.body -- contains form data
  res.render('tripresult', {title:"Trip Planning"});
});

app.get('/trip', function(req, res) {
	
	res.render('trip', {title:"Trip Planning"});
});




//ABOUT 
app.get('/about', function(req, res) {
	res.render('about', {title:"About"});
});


//AGENCIES NAVIGATOR
app.get('/agencies', function(req, res) {
	//res.render('agencies', {title:"Agencies"});
	agents = agenciesEngine.getAgencies();
	//console.log("AGENTS ");
	//console.log(agents);
	res.render('agencies',{title:"Transit Agencies", agencies:agenciesEngine.getAgenciesStatic()});
	//res.render('agencies',{title:"Transit Agencies", agencies:agenciesEngine.getAgencies()});
});



//Post Delegater
app.post('/post', function(req, res){ // Specifies which URL to listen for

  //will need to add logic to control mode flow in post.html using handlebars.js
	
  // req.body -- contains form data

  var fname = req.body.fname;
  var lname = req.body.lname;
  var email = req.body.email;
  var message = req.body.message;
  var mode = req.body.mode;  //all forms need a mode for the post delegator
  var Poster = require('./poster');
  var poster_conroller = new Poster(req);
  //console.log(poster_conroller.greetingText());
  var greeting = poster_conroller.greetingText();
  //var fileUpdate = poster_controller.writeContact(req.body);

  
  res.render('post', {title:"Post", fname:fname, lname:lname, message:message, email: email, mode:mode, greeting:greeting });
});

//Contact
app.get('/contact', function(req, res) {
	res.render('contact', {title:"Contact"});
});






//app.listen(3000);
app.listen(1337, '127.0.0.1');


//heroku specific
/*app.listen(process.env.PORT || 5000, function(){
  console.log("Express server listening on port %d in %s mode", this.address().port, app.settings.env);
});
*/
