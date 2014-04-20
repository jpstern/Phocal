
var express = require("express")
  , path = require('path');

module.exports = function configure(app) {

    app.set('port', process.env.PORT || 3000);
    app.use(express.favicon());
    app.use(express.logger('dev'));
    app.use(express.json());
    app.use(function(req, res, next) {
        req.hash = req.headers["x-hash"];
        next();
    });
    app.use(express.urlencoded());
    app.use(express.methodOverride());
    app.use(app.router);

    app.use(function(err, req, res, next){
        console.error(err.stack);
        res.send(500, {"Error": err.message});
    });
}
