
class ModelDefinition   
   constructor: ->
      @attributes = {}

   defineAttribute: (attribute, options) ->
      console.log "defining attribute: ",attribute, options
      options ?= {}
      options.readable ?= true
      options.writeable ?= true
      console.log "after aplying defaults: ", options

      @attributes[attribute] = options

   isAttributeDefined: (attribute) ->
      !!@attributes[attribute]

   getAttributeNames: ->
      result = []
      for own attr, def of @attributes
         result.push attr
      result
   
class Model
   constructor: (values) ->
      @_attributeValues = {}

      this.massAssignValues(values || {})

      if "function" is typeof this.__defineGetter__
         this.__installGetters()

      if "function" is typeof this.__defineSetter__
         this.__installSetters()

   get: (attr) ->
      def = this.getDefinition().attributes[attr]

      throw "undefined attribute: #{attr}" if not def
      throw "attribute '#{attr}' is not readable" if not def.readable

      this.__retrieveValue(attr)

   set: (attr, value) ->
      def = this.getDefinition().attributes[attr]

      throw "undefined attribute: #{attr}" if not def
      throw "attribute '#{attr}' is not writeable" if not def.writeable
      
      this.__assignValue(attr, value)

   massAssignValues: (values) ->
      def = this.getDefinition()

      for own attribute, value of values
         try this.set(attribute, value) catch e
   
   getDefinition: ->
      Model.__definitions[@constructor]

   getAttributes: ->
      this.getDefinition().getAttributeNames()

# private
   __retrieveValue: (attribute) ->
      @_attributeValues[attribute]

   __assignValue: (attribute, value) ->
      @_attributeValues[attribute] = value

   __installGetters: ->
      def = this.getDefinition()
      for attr in this.getAttributes()
         continue unless def.attributes[attr].readable
         this.__installGetter(attr)

   __installGetter: (attr) ->
      this.__defineGetter__ attr, ->
         this.get(attr)

   __installSetters: ->
      def = this.getDefinition()

      for attr in this.getAttributes()
         continue unless def.attributes[attr].writeable
         this.__installSetter(attr)

   __installSetter: (attr) ->
      this.__defineSetter__ attr, (value) ->
         this.set(attr, value)

Model.__definitions = {}

Model.define = (model, attribute, options) ->
   (Model.__definitions[model] ||= new ModelDefinition()).defineAttribute(attribute, options)

exports.Model = Model