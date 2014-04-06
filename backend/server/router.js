var mongo 	 = require("./database.js"),
	routes 	= require("./routes.js");

module.exports = function(app) {

	mongo.connect(function(msg) {
		if(msg == null) {
			console.log("Mongo Connected!");

			// define API routes here
			app.get('/', routes.index);
			app.get('/db', routes.db);

		} else {
			console.log(msg);
		}
	});
}
