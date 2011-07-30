###
   Returns the global object assigned to the JavaScript interpreter.  In most
   standards compliant browsers this is the "window" object - but in other
   JavaScript interpreters (like Rhino) the window object is undefined.

   This method is happily taken from 
    http://www.nczonline.net/blog/2008/04/20/get-the-javascript-global/

   @author Nicholas C. Zakas
###
exports.getGlobalObject = ->
  `function(){ return this; }.call(null)`

###
   Mixes all methods from the givingClass's prototype into the receivingClass's
   prototype.  

   Callbacks can be defined on the givingClass to allow it to perform other 
   changes as necessary.  The callbacks must be named __mixing or __mixed 
   (before and after callbacks respectively) and must be defined on the class 
   level (not on the prototype).

   @param {Function} receivingClass
   @param {Function} givingClass
###
exports.mixin = (receivingClass, givingClass) ->
   if "function" is typeof givingClass.__mixing
      givingClass.__mixing receivingClass
   
   methods = exports.instanceMethods givingClass.prototype

   receivingClass.prototype[method] = givingClass.protoype[method] for method in methods

   if "function" is typeof givingClass.__mixed
      givingClass.__mixed receivingClass

###
   Returns an array of all the function names on an object
   @param {Object} object
###
exports.instanceMethods = (object) ->
   result = []
   proto = if object.constructor is Function then object else object.constructor.prototype

   result = for own property, value of proto
      if "function" is typeof value then value else null

   result.compact()
};

