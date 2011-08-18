_ = require("underscore")

class exports.ModelDefinition

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
      options ?= {}

      throw "already defined: #{attr}" if this.isAttributeDefined(attr)

      throw "dependents are required" if not options.dependents

      options.readable = "function" is typeof options.getter
      options.writeable = "function" is typeof options.setter

      @computedAttributes[attr] = options

   getAttributeDefinition: (attr) ->
      @attributes[attr] || @computedAttributes[attr]

   isAttributeDefined: (attr) ->
      !!(this.getAttributeDefinition(attr))

   getAttributeNames: ->
      result = []
      for own attr, def of @attributes
         result.push attr
      for own attr, def of @computedAttributes
         result.push attr
      result

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