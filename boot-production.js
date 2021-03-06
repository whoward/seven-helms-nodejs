var coffee = require("coffee-script");
var fs = require("fs");
var path = require("path");

// assign the environment if undefined
process.env.NODE_ENV = process.env.NODE_ENV || "production";
process.env.PORT = process.env.PORT || 80;

console.log("node environment:", process.env.NODE_ENV);
console.log("node port:", process.env.PORT);

// get the path to the server coffeescript file
server_file = path.join(__dirname, "server.coffee");

// read and evaluate the server coffeescript
fs.readFile(server_file, function(err, data) {
   if(err) { throw err; }
   eval(coffee.compile(data.toString()));
});