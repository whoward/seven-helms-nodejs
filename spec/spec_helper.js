// add the root directory to the load path
require.paths.push("#{__dirname}/../");

// this file is loaded automatically by jasmine-node, as is any file containing "helper" in it
var couchdb = require("lib/database").couchdb;

TestHelper = {};

TestHelper.stub_database = function() {
   spyOn(couchdb, 'initialize');
   spyOn(couchdb, 'get');
   spyOn(couchdb, 'view');
   spyOn(couchdb, 'save');
   spyOn(couchdb, 'merge');
   spyOn(couchdb, 'remove');
};

beforeEach(function() {
   App = {
      root: "#{__dirname}/../",
      port: 3000,
      environment: "test",
      design_documents: []
   };

   TestHelper.stub_database();

   this.addMatchers({
      toBeAFunction: function() { return typeof(this.actual) === "function"; },
      toBeEmpty: function() { return this.actual.length === 0; },
      toInclude: function(x) { return this.actual.indexOf(x) >= 0; },
      toBeAnInstanceOf: function(klass) { return this.actual instanceof klass; },
      toBeValid: function() { return this.actual.validate() === true; },
      toBeInvalid: function() { return this.actual.validate() === false; }
   })
});