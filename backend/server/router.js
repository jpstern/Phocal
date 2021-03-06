var mongo 	 = require("./database.js"),
	Photos 	= require("./photos.js");

module.exports = function(app) {

	mongo.connect(function(msg) {
		if(msg == null) {

			app.get("/", function(req,res) {
				res.send('<html><body><form action="/photos" method="post" enctype="multipart/form-data"><input type="text" name="time"><input type="text" name="lat"><input type="text" name="lng"><input type="file" name="photo" multiple=""><input type="submit"></form></body></html>')
			});

			var photos = new Photos();
			// define API photo here
			app.get('/photos', photos.get);
			app.post('/photos', photos.post);
			app.post('/photo/:id/vote', photos.post_vote);

		} else {
			console.log(msg);
		}
	});
}
