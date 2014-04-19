var  mongo         = require("./database.js"),
     multiparty    = require('multiparty'),
     path          = require('path'),
     async         = require('async'),
     fs            = require('fs'),
     exif          = require('exif-parser');

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
    photos.ensureIndex({ _id: 1 },{  background:true, unique:true, dropDups:true });

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
        photos.find(query).limit(20).sort({time:-1}).toArray(
            db_response(req, res, next));
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
        photos.update({_id:req.params.id}, {$addToSet:{votes:req.hash}}, db_response(req, res, next));
    }

    // saves file to s3 and returns the hash
    function saveFile(file, callback) {

        if (file.size == 0) {
            callback("Invalid File");
        }

        fs.readFile(file.path, function (err, data) {
            var parser = require('exif-parser').create(data);
            var exif = parser.parse();

            var metadata = {
                _id: file.hash,
                size: file.size,
                type: file.headers["content-type"],
                loc: {
                    type: "Point",
                    coordinates: [
                        // TODO: figure out how to do file location...
                        parseFloat(exif.tags.GPSLongitude) || 0,
                        parseFloat(exif.tags.GPSLatitude) || 0
                    ]
                },
                time: new Date()
            }

            var put = s3.putBuffer(data, metadata._id, {
                'Content-Length': metadata.size,
                'Content-Type': metadata.type,
                'x-amz-acl': 'public-read' // ensure public
            }, function(err, res) {
                if (!err && 200 == res.statusCode) {
                    photos.insert(metadata, function(err, docs){
                        if (err) callback(err);
                        else callback(null, docs[0]);
                    });
                } else {
                    callback({"error": "Can't Save to S3"});
                }
            });

            console.log("Posted Image URL:", put.url);

        });




    }

    function db_response(req, res, next) {
        return function(err, docs) {
            if (err) next(err);


                            console.log(docs);

            for (var i in docs) {
                var doc = docs[i];

                doc = parsePhoto(doc, req);
            }
            res.send(docs);
        }
    }
}

function parsePhoto(photo, req) {

    if(!photo.votes) {
        photo.votes = [];
    }
    photo.didVote = contains(photo.votes, req.hash);
    photo.votes = photo.votes.length;

    photo.lat = photo.loc.coordinates[1];
    photo.lng = photo.loc.coordinates[0];
    delete photo.loc;

    return photo
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
