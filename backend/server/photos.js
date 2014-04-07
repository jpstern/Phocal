var  mongo     = require("./database.js"),
     Busboy    = require('busboy'),
     fs        = require('fs'),
     path      = require('path'),
     uuid      = require('node-uuid');

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

    // GET /photos
    this.get = function(req, res){

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

        photos.find(query, {_id:0}).limit(20).toArray(db_response(req, res));
    };

    // POST /phots
    this.post = function(req, res) {

        var busboy = new Busboy({ headers: req.headers });
        var metadata = {};

        busboy.on('field', function(key, val, valTruncated, keyTruncated) {
            console.log('Field [' + key + ']: value: ' + val);
            metadata[key] = val;
        });


        // TODO: this assumes only one photo is updated, handle multiples?
        busboy.on('file', function(fieldname, file, filename, encoding, mimetype) {

            file.on('data', function(data) {
                // when file data is retrieved, put to S3

                var headers = {
                    'Content-Length': data.length,
                    'Content-Type': mimetype,
                    'x-amz-acl': 'public-read' // ensure public
                };

                // generate unique id for photo
                metadata.id = uuid.v4();
                var put = s3.put(metadata.id, headers);
                put.end(data);

                console.log(put.url);

                put.on('error', function(err) {
                    res.send(404, {"error": err});
                });

                // after
                put.on('response', function(put_res){
                    if (200 == put_res.statusCode) {

                        photos.insert({
                            loc: {
                                type: "Point",
                                coordinates: [ metadata.lng, metadata.lat ]
                            },
                            id: metadata.id,
                            time: metadata.time || new Date()
                        }, db_response(req, res));

                    } else {
                        res.send(404, {"error": "Can't Save to S3"});
                    }
                });
            });
        });

        req.pipe(busboy);
    }

    function db_response(req, res) {
        return function(err, docs) {
            if(err) {
                res.send(404, {"error":err});
            } else {
                res.send(docs);
            }
        }
    }
}
