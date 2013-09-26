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

app.get('/route/:id', function(req, res) {
	var entry = busrEngine.getBusrEntry(req.params.id);
	res.render('route',{title:entry.title, busr:entry});
});

app.listen(3000);