ModelDefinition = require("./definition").ModelDefinition
ComputedAttributeObserver = require("./computed_attribute_observer").ComputedAttributeObserver

class Model
   get: (attr) ->
      def = this.getAttributeDefinition(attr)

      throw "undefined attribute: #{attr}" if not def
      throw "attribute '#{attr}' is not readable" if not def.readable
      
      this.__retrieveValue(attr)

   set: (attr, value) ->
      def = this.getAttributeDefinition(attr)

      throw "undefined attribute: #{attr}" if not def
      throw "attribute '#{attr}' is not writeable" if not def.writeable
      
      this.__assignValue(attr, value)

   massAssignValues: (values) ->
      for own attribute, value of values
         try this.set(attribute, value) catch e

   getDefinition: ->
      Model.__definitions[@constructor]
      
   getAttributeDefinition: (attr) ->
      def = this.getDefinition()

      def.attributes[attr] || def.computedAttributes[attr]

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
   __retrieveValue: (attr) ->
      def = this.getAttributeDefinition(attr)

      if "function" is typeof def.getter
         def.getter.call(this)
      else
         @_attributeValues[attr]

   __assignValue: (attr, value) ->
      this.__notifyObservers(attr, "attributeValueWillChange")

      def = this.getAttributeDefinition(attr)

      if "function" is typeof def.setter
         def.setter.call(this, value)
      else
         @_attributeValues[attr] = value

      this.__notifyObservers(attr, "attributeValueDidChange")

   __installGetters: ->
      for attr in this.getDefinition().getAttributeNames()
         continue unless this.getAttributeDefinition(attr).readable
         this.__installGetter(attr)

   __installGetter: (attr) ->
      this.__defineGetter__ attr, ->
         this.get(attr)

   __installSetters: ->
      for attr in this.getDefinition().getAttributeNames()
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

Model.__construct = (model) ->
   model._attributeValues = {}
   model._observers = {}

   if "function" is typeof model.__defineGetter__
      model.__installGetters()

   if "function" is typeof model.__defineSetter__
      model.__installSetters()

   dependents = model.getDefinition().getComputedAttributeDependents()

   if dependents
      model.__computedAttributeObserver = new ComputedAttributeObserver(model, dependents)

Model.getModelDefinition = (model) ->
   return Model.__definitions[model] ?= new ModelDefinition()

Model.attribute = (model, attribute, options) ->
   Model.getModelDefinition(model).defineAttribute(attribute, options)

Model.computedAttribute = (model, attribute, options) ->
   Model.getModelDefinition(model).defineComputedAttribute(attribute, options)

exports.Model = Model