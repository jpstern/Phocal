var  mongo = require("./database.js"),
     Busboy = require('busboy'),
     fs = require('fs'),
     path = require('path');


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

        var busboy = new Busboy({ headers: req.headers });

        var uploaded_file;
        busboy.on('file', function(fieldname, file, filename, encoding, mimetype) {
            console.log('File [' + fieldname + ']: filename: ' + filename + ', encoding: ' + encoding);

            var saveTo = path.join(__dirname, "../tmp/", path.basename(fieldname));
            file.pipe(fs.createWriteStream(saveTo));

            // file.on('data', function(data) {
            //     console.log('File [' + fieldname + '] got ' + data.length + ' bytes');
            //     uploaded_file = data;
            // });
            //
            // file.on('end', function() {
            //     console.log('File [' + fieldname + '] Finished');
            // });
        });

        var metadata = {};
        busboy.on('field', function(key, val, valTruncated, keyTruncated) {
            console.log('Field [' + key + ']: value: ' + val);
            metadata[key] = val;
        });

        busboy.on('finish', function() {
            console.log(metadata);
            console.log(uploaded_file);
            //photos.insert(req.body, db_response(req, res));
            db_response(req, res)(null,{});
        });

        req.pipe(busboy);
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
