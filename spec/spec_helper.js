// this file is loaded automatically by jasmine-node, as is any file containing "helper" in it

beforeEach(function() {
  this.addMatchers({
    toBeAFunction: function() { return typeof(this.actual) === "function"; }
  })
});
