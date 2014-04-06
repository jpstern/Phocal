var mongo = require("./database.js");

/*
    /photos GET, POST endpoints
*/

module.exports = function() {

    var photos = mongo.db.collection("photos");

    // GET /photos
    this.get = function(req, res){
        photos.find({}, {_id:0}).toArray(db_response(req, res));
    };

    // POST /phots
    this.post = function(req, res) {
        photos.insert(req.body, db_response(req, res));
    }

    function db_response(req, res) {
        return function(err, docs) {
            if(err) {
                res.send(404, err);
            } else {
                res.send(docs);
            }
        }
    }
}





/*
// db test
exports.db = function(req, res){
    mongo.db.collection("test", function(err, collection){
        collection.insert({ msg: "hello world" }, function(err, docs){
            if(err) throw err
            res.send(docs);
        });
    });
};
*/
