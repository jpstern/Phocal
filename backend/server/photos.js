var mongo = require("./database.js");

/*
    /photos GET, POST endpoints
*/

module.exports = function() {

    this.get = function(req, res){
        res.send("hello world");
    };

    this.post = function(req, res) {
        res.send("done");
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
