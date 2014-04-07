var mongo 	 = require("./database.js"),
	Photos 	= require("./photos.js");

module.exports = function(app) {

	mongo.connect(function(msg) {
		if(msg == null) {

			var photos = new Photos();
			// define API photo here
			app.get('/photos', photos.get);
			app.post('/photos', photos.post);

		} else {
			console.log(msg);
		}
	});
}
