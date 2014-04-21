var  mongo         = require("./database.js"),
     multiparty    = require('multiparty'),
     path          = require('path'),
     fs            = require('fs'),
     request       = require('request');

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
            if (req.hash) {
                query.hash = req.hash;
            }
        }
        console.log(query);

		res.setHeader('Cache-Control', 'private, max-age=1');
		res.setHeader('Expires', new Date().toUTCString());
        photos.find(query).limit(20).sort({time:-1}).toArray(
            db_response(req, res, next));
    };

    // POST /photos
    this.post = function(req, res, next) {

        var form = new multiparty.Form({
            hash: "sha1"
        });

        form.parse(req, function(err, fields, files) {
            if (err || !files.photo) {
                res.json(502, {error: err || "No Upload"});
                return;
            }
            saveFile(files.photo[0], fields, req.hash, db_response(req, res, next));
        });
    }

    // POST /photo/:id/hash (pass hash in body)
    this.post_vote = function(req, res, next) {
        if (!req.hash) throw new Error("Invalid Hash");

        photos.update({_id:req.params.id}, {$addToSet:{votes:req.hash}}, db_response(req, res, next));
    }

    // saves file to s3 and returns the hash
    function saveFile(file, fields, hash, callback) {

        if (file.size === 0) {
            return callback(new Error("Invalid File"));
        }

        try {
            var time_int = parseInt(fields.time[0]);
            var time = new Date(time_int);
            var lat = parseFloat(fields.lat[0]);
            var lng = parseFloat(fields.lng[0]);

            if (!lat || !lng || !time) {
                throw -1;
            }
        } catch (err) {
            return callback(new Error("All 'time', 'lat', or 'lng' fields required."));
        }

        var metadata = {
            _id: file.hash,
            size: file.size,
            type: file.headers["content-type"],
            loc: {
                type: "Point",
                coordinates: [
                    lng || 0,
                    lat || 0
                ]
            },
            hash: hash,
            time: time || new Date()
        }

        getGeocodeDescription(lat, lng, function(err, geo_name) {

            metadata.label = geo_name;

            var put = s3.put(metadata._id, {
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
            for (var i in docs) {
                var doc = docs[i];

                doc = parsePhoto(doc, req);
            }
            res.send(docs);
        }
    }
}

function getGeocodeDescription(lat, lng, callback) {
    var url = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
    url += lat + "," + lng
    url += "&result_type=point_of_interest|neighborhood|political&sensor=false&key="
    url += process.env.GEOCODE_KEY

    request({url:url , json:true}, function (error, response, body) {
        if (!error && response.statusCode == 200) {
            console.log(body);
            callback(null, parseGeocodeData(body.results));
        } else {
            callback(new Error("Geocode Error"));
        }
    })
}

function parseGeocodeData(results) {
    try {
        return results[0]["address_components"][0]["long_name"];
    } catch (err) {
        return null;
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

function contains(a, obj) {
    var i = a.length;
    while (i--) {
        if (a[i] === obj) {
            return true;
        }
    }
    return false;
}
