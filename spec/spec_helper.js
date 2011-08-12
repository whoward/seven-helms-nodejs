// this file is loaded automatically by jasmine-node, as is any file containing "helper" in it

beforeEach(function() {
  this.addMatchers({
    toBeAFunction: function() { return typeof(this.actual) === "function"; },
    toBeEmpty: function() { return this.actual.length === 0; },
    toInclude: function(x) { return this.actual.indexOf(x) >= 0; },
    toBeAnInstanceOf: function(klass) { return this.actual instanceof klass; },
    toBeValid: function() { return this.actual.validate() === true; },
    toBeInvalid: function() { return this.actual.validate() === false; }
  })
});
