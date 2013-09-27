var express = require('express');
var app = express();

var hbs = require('hbs');

var busrEngine = require('./busr');

app.set('view engine', 'html');
app.engine('html', hbs.__express);
app.use(express.bodyParser());

app.use(express.static('public'));

app.get('/', function(req, res) {
	res.render('index',{title:"Busr Transitor", entries:busrEngine.getBusrEntries()});
});

app.get('/about', function(req, res) {
	res.render('about', {title:"About"});
});

app.get('/map', function(req, res) {
	res.render('map', {title:"Map"});
});

app.get('/agencies', function(req, res) {
	res.render('agencies', {title:"Map"});
});

app.get('/route/:id', function(req, res) {
	var entry = busrEngine.getBusrEntry(req.params.id);
	res.render('route',{title:entry.title, busr:entry});
});

//app.listen(5000);

app.listen(process.env.PORT || 5000, function(){
  console.log("Express server listening on port %d in %s mode", this.address().port, app.settings.env);
});