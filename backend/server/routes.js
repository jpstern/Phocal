var mongo = require("./database.js");

// main page
exports.index = function(req, res){
    res.send('hello world');
};

// db test
exports.db = function(req, res){
    mongo.db.collection("test", function(err, collection){
        collection.insert({ msg: "hello world" }, function(err, docs){
            if(err) throw err
            res.send(docs);
        });
    });
};
