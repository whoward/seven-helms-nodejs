var coffee = require("coffee-script");
var fs = require("fs");
var path = require("path");

server_file = path.join(__dirname, "server.coffee")


fs.readFile(server_file, function(err, data) {
   if(err) { throw err; }
   eval(coffee.compile(data.toString()));
});