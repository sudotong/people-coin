module.exports = require('./node_modules/twitter-node-client/lib/Twitter');

var express = require('express');
var app = express();
var bodyParser = require('body-parser');

var error = function (err, response, body) {
    console.log('ERROR [%s]', JSON.stringify(err));
};
var success = function (data) {
    console.log('Data [%s]', data);
};

var config = {
    "consumerKey": "10ayrkoJP0uWrpJGprimwHeOR",
    "consumerSecret": "uGtuDJOeXrVE1WBBYk7sHisI9nY1K253p8iWHcAKwlCkO5wsUo",
    "accessToken": "1529736870-x5FnVEN8T8xofIXvzQIf0MtKC9DQK6Gf66mRh8v",
    "accessTokenSecret": "gjcsZv9OswplHO6fd8YRWCzujtDVmAh2H1QLDPbAxsJJI"
};

var twitter = new module.exports.Twitter(config);

app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
}));

/*
 * To connect to a front end app (i.e. AngularJS) store all your files you will *
 * statically store in declared below (i.e. ./public) *
*/

app.use(express.static('public'));

//post to retrieve user data
app.get('/twitter/user', function (req, res) {
	var username = req.query.username;
	var data = twitter.getUser({ screen_name: username}, function(error, response, body){
		console.log('error', error);
		res.status(404).send({
			"error" : "User Not Found"
		});
	}, function(data){
		console.log('data', data);
		res.send({
			result : {
				"userData" : data
			}
		});
	});
});


var server = app.listen(3000, function () {
  	var host = server.address().address;
  	var port = server.address().port;
});

// run the app and go to url http://localhost:3000/twitter/user?username=sudotong