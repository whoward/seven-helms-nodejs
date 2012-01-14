
class global.Kernel
  ###
     Returns the global object assigned to the JavaScript interpreter.  In most
     standards compliant browsers this is the "window" object - but in other
     JavaScript interpreters (like Rhino) the window object is undefined.

     This method is happily taken from 
      http://www.nczonline.net/blog/2008/04/20/get-the-javascript-global/

     @author Nicholas C. Zakas
  ###
  @get_global_object = ->
    (-> return this).call(null)

  ###
     Mixes all methods from the mixin's prototype into the base's
     prototype.  

     Callbacks can be defined on the mixin to allow it to perform other 
     changes as necessary.  The callbacks must be named __mixing or __mixed 
     (before and after callbacks respectively) and must be defined on the class 
     level (not on the prototype).

     This method will not mix a module in that has already been mixed in (mixed
     modules are tracked with the class variable __mixing, which is added the
     first time it is called)

     @param {Function} base
     @param {Function} mixin
  ###
  @mixin = (base, mixin) ->
     base.__modules ?= []

     if base.__modules.indexOf(mixin) >= 0
        return
     else
        base.__modules.push(mixin)

     if "function" is typeof mixin.__mixing
        mixin.__mixing base
     
     methods = Kernel.instance_methods mixin.prototype

     base.prototype[fn] = mixin.prototype[fn] for fn in methods

     if "function" is typeof mixin.__mixed
        mixin.__mixed base

  ###
    Intended to be called in the constructor of a mixed class, calls constructors
    of mixed in modules if defined.
  ###
  @construct_mixins = (instance) ->
    modules = (instance.constructor.__modules || [])

    for module in modules
      module.__construct(instance) if "function" is typeof module.__construct

  ###
     Returns an array of all the instance variables
     @param {Object} object
  ###
  @instance_variables = (object) ->
     result = []
     for own key, val of object
        result.push(key) if "function" isnt typeof val
     result
     

  ###
     Returns an array of all the function names on an object
     @param {Object} object
  ###
  @instance_methods = (object) ->
     result = []
     proto = if object.constructor is Function then object else object.constructor.prototype

     for own key, value of proto
        result.push(key) if "function" is typeof value

     result

  ###
     Returns a deep copy of the given object. Please don't contain recursive
     pointers - it would probably be very bad if you did. (infinite loop)
     @param {Object} object
  ###
  @duplicate = (object) ->
    newObj = if (object instanceof Array) then [] else {}
    for i of object
      if object[i] and typeof object[i] == "object"
        newObj[i] = exports.duplicate(object[i])
      else
        newObj[i] = object[i]
    newObj

  ###
     Resolves the given string path and returns the object it references to.
     This is better than eval because nothing is actually evaluated, only looked
     up.
     @param {String} path
     @param {Object} object
  ###
  @resolve_path = (path, object) ->
    object = object or exports.get_global_object()
    components = path.split(".")
    current = object
    
    for component in components
      current = current[component]
      if "undefined" is typeof current
        throw "component '#{component}' in path '#{path}' is not defined" 

    current