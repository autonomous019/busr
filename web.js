var express = require('express');
var app = express();

var hbs = require('hbs');

var routesEngine = require('./routes');
var busrEngine = require('./busr');
var stopsEngine = require('./stops')


app.set('view engine', 'html');
app.engine('html', hbs.__express);
app.use(express.bodyParser());

app.use(express.static('public'));

app.get('/', function(req, res) {
	res.render('index',{title:"Busr Transitor", entries:busrEngine.getBusrEntries()});
});

app.get('/routes', function(req, res) {
	res.render('routes',{title:"MTA Routes", routes:routesEngine.getRoutes()});
});

app.get('/stops', function(req, res) {
	res.render('stops',{title:"MTA Stops"});
});

app.get('/about', function(req, res) {
	res.render('about', {title:"About"});
});

app.get('/map', function(req, res) {
	res.render('map', {title:"Map"});
});

app.get('/agencies', function(req, res) {
	res.render('agencies', {title:"Agencies"});
});

app.get('/route/:id', function(req, res) {
	var route = routesEngine.getRoute(req.params.id);
	res.render('route',{id:route.id, route:route});
});


app.get('/stop/:id', function(req, res) {
	var route = stopsEngine.getStop(req.params.id);
	res.render('stop',{id:stop.id, stop:stop});
});


//app.listen(3000);
app.listen(1337, '127.0.0.1');
//heroku specific
/*app.listen(process.env.PORT || 5000, function(){
  console.log("Express server listening on port %d in %s mode", this.address().port, app.settings.env);
});
*/
