var  mongo         = require("./database.js"),
     multiparty    = require('multiparty'),
     path          = require('path'),
     async         = require('async'),
     fs            = require('fs'),
     exif          = require('exif');

     var s3 = require("knox").createClient({
         key: process.env.AWS_KEY,
         secret: process.env.AWS_SECRET,
         bucket: process.env.AWS_S3_BUCKET
     });

/*
    /photos GET, POST endpoints
*/

module.exports = function() {

    var photos = mongo.db.collection("photos");
    photos.ensureIndex({ loc: "2dsphere" },{ background:true });
    photos.ensureIndex({ id: 1 },{  background:true, unique:true, dropDups:true });

    // GET /photos
    this.get = function(req, res, next){

        var point = {
			type : "Point" ,
			coordinates : [ parseFloat(req.query.lng),
							parseFloat(req.query.lat) ]
		}
		var query = {
			loc: {
				$near: {
					$geometry: point,
					$maxDistance : 3200 //meh, 2 miles
				}
			},
            // TODO: time range, sort??
            //time: { $lt: ,  }
		};

        // TODO: REMOVE THIS SHIT LATER
        if(!req.query.lng || !req.query.lat) {
            query = {};
        }
        photos.find(query, {_id:0}).limit(20).toArray(function(err, docs) {
            console.log(docs)
            for (var i in docs) {
                var doc = docs[i];
                if(!doc.votes) {
                    doc.votes = [];
                }
                doc.didVote = contains(doc.votes, req.hash);
                doc.votes = doc.votes.length;

                doc.lat = doc.loc.coordinates[1] || 0;
                doc.lng = doc.loc.coordinates[0] || 0;
                delete doc.loc;
            }
            db_response(req, res, next)(err,docs);
        });
    };

    // POST /photos
    this.post = function(req, res, next) {

        var form = new multiparty.Form({
            hash: "sha1"
        });

        // form.parse(req);
        // form.on("part", function(part){
        //     console.log(part.name);
        // });

        form.parse(req, function(err, fields, files) {
            if (err && !files.photo) {
                res.json(502, {error: err || "No Upload"});
                return;
            }
            async.map(files.photo, saveFile, db_response(req, res, next));
        });
    }

    // POST /photo/:id/hash (pass hash in body)
    this.post_vote = function(req, res, next) {
        if (!req.hash) throw new Error("Invalid Hash");
        photos.update({id:req.params.id}, {$addToSet:{votes:req.hash}}, db_response(req, res, next));
    }

    // saves file to s3 and returns the hash
    function saveFile(file, callback) {

        if (file.size == 0) {
            callback("Invalid File");
        }

        var metadata = {
            id: file.hash,
            size: file.size,
            type: file.headers["content-type"],
            loc: {
                type: "Point",
                coordinates: [
                    // TODO: figure out how to do file location...

                    parseFloat(file.lng) || 0,
                    parseFloat(file.lat) || 0
                ]
            },
            time: file.time || new Date()
        }

        var ExifImage = exif.ExifImage;
        new ExifImage({ image : file.path }, function (error, exifData) {
            if (error) return callback(Error("Bad Image"));

            metadata.exif = exifData;

            var put = s3.put(metadata.id, {
                'Content-Length': metadata.size,
                'Content-Type': metadata.type,
                'x-amz-acl': 'public-read' // ensure public
            });

            console.log("Posted Image URL:", put.url);

            // TODO: see if we can use putStream.. don't use tmp file save.
            fs.createReadStream(file.path).pipe(put);

            put.on('error', function(err) {
                callback(err);
            });

            put.on('response', function(res){
                if (200 == res.statusCode) {
                    photos.insert(metadata, callback);
                } else {
                    callback({"error": "Can't Save to S3"});
                }
            });

        });

    }

    function db_response(req, res, next) {
        return function(err, docs) {
            if (err) next(err);
            res.send(docs);
        }
    }
}

// TODO: move to util...
function contains(a, obj) {
    var i = a.length;
    while (i--) {
        if (a[i] === obj) {
            return true;
        }
    }
    return false;
}
