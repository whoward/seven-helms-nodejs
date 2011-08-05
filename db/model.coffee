_ = require("underscore")

class ModelDefinition   
   constructor: ->
      @attributes = {}
      @computedAttributes = {}

   defineAttribute: (attr, options) ->
      throw "already defined: #{attr}" if this.isAttributeDefined(attr)

      options ?= {}
      options.readable ?= true
      options.writeable ?= true

      @attributes[attr] = options

   defineComputedAttribute: (attr, options) ->
      throw "already defined: #{attr}" if this.isAttributeDefined(attr)

      throw "dependents are required" if not options.dependents

      options.readable = "function" is typeof options.getter
      options.writeable = "function" is typeof options.setter

      @computedAttributes[attr] = options

   isAttributeDefined: (attr) ->
      !!(@attributes[attr] || @computedAttributes[attr])

   getComputedAttributeDependents: ->
      result = []
      for own attr, def of @computedAttributes
         result = result.concat def.dependents
      _.unique(result)

   getAttributesDependentOn: (attribute) ->
      result = []
      for own attr, def of @computedAttributes
         result.push(attr) if def.dependents.indexOf(attribute) >= 0
      result

   getAttributeNames: ->
      result = []
      for own attr, def of @attributes
         result.push attr
      for own attr, def of @computedAttributes
         result.push attr
      result

class ComputedAttributeObserver
   constructor: (observee, dependents) ->
      @observee = observee

      for dependent in dependents
         @observee.addObserver(dependent, this)

   attributeValueWillChange: (attr) ->
      this.notify attr, "attributeValueWillChange"

   attributeValueDidChange: (attr) ->
      this.notify attr, "attributeValueDidChange"

   notify: (attr, event) ->
      deps = @observee.getDefinition().getAttributesDependentOn(attr)
      for dependency in deps
         @observee.__notifyObservers(dependency, event)

class Model
   constructor: (values) ->
      @_attributeValues = {}
      @_observers = {}

      if "function" is typeof this.__defineGetter__
         this.__installGetters()

      if "function" is typeof this.__defineSetter__
         this.__installSetters()

      this.massAssignValues(values || {})

      dependents = this.getDefinition().getComputedAttributeDependents()

      if dependents
         @computedAttributeObserver = new ComputedAttributeObserver(this, dependents)

   get: (attr) ->
      def = this.getAttributeDefinition(attr)

      throw "undefined attribute: #{attr}" if not def
      throw "attribute '#{attr}' is not readable" if not def.readable

      this.__retrieveValue(def, attr)

   set: (attr, value) ->
      def = this.getAttributeDefinition(attr)

      throw "undefined attribute: #{attr}" if not def
      throw "attribute '#{attr}' is not writeable" if not def.writeable
      
      this.__assignValue(def, attr, value)

   massAssignValues: (values) ->
      for own attribute, value of values
         try this.set(attribute, value) catch e

   getDefinition: ->
      Model.__definitions[@constructor]

   getAttributeDefinition: (attr) ->
      def = this.getDefinition()

      def.attributes[attr] || def.computedAttributes[attr]

   getAttributes: ->
      this.getDefinition().getAttributeNames()

   addObserver: (attr, observer) ->
      def = this.getAttributeDefinition(attr)

      throw "undefined attribute: #{attr}" if not def
      throw "attribute '#{attr}' is not readable" if not def.readable

      @_observers[attr] ?= []
      unless @_observers[attr].indexOf(observer) >= 0
         @_observers[attr].push(observer)

   removeObserver: (attr, observer) ->
      def = this.getAttributeDefinition(attr)

      throw "undefined attribute: #{attr}" if not def
      throw "attribute '#{attr}' is not readable" if not def.readable

      @_observers[attr] ?= []
      if (index = @_observers[attr].indexOf(observer)) >= 0
         @_observers[attr].splice(index, 1)
         

# private
   __retrieveValue: (def, attr) ->
      if "function" is typeof def.getter
         def.getter.call(this)
      else
         @_attributeValues[attr]

   __assignValue: (def, attr, value) ->
      this.__notifyObservers(attr, "attributeValueWillChange")
      
      if "function" is typeof def.setter
         def.setter.call(this, value)
      else
         @_attributeValues[attr] = value
      
      this.__notifyObservers(attr, "attributeValueDidChange")

   __installGetters: ->
      for attr in this.getAttributes()
         continue unless this.getAttributeDefinition(attr).readable
         this.__installGetter(attr)

   __installGetter: (attr) ->
      this.__defineGetter__ attr, ->
         this.get(attr)

   __installSetters: ->
      for attr in this.getAttributes()
         continue unless this.getAttributeDefinition(attr).writeable
         this.__installSetter(attr)

   __installSetter: (attr) ->
      this.__defineSetter__ attr, (value) ->
         this.set(attr, value)

   __notifyObservers: (attr, method) ->
      observers = @_observers[attr]

      return if not observers


      for observer in observers
         observer[method].call(observer, attr) if "function" is typeof observer[method]

Model.__definitions = {}

Model.attribute = (model, attribute, options) ->
   (Model.__definitions[model] ?= new ModelDefinition()).defineAttribute(attribute, options)

Model.computedAttribute = (model, attribute, options) ->
   (Model.__definitions[model] ?= new ModelDefinition()).defineComputedAttribute(attribute, options)

exports.Model = Model