Class = require("./class")
Model = require("./model/model").Model
ValidatableModel = require("./validatable_model/model").ValidatableModel

couchdb = require("./database").couchdb

class CouchModel
   constructor: (params) ->
      Class.constructMixins(this)
      this.massAssignValues(params)
      this.type = @constructor.model_type

   save: (callback) ->
      # first validate the values, if not valid then return quickly
      validation = this.validate()

      return validation if not validation

      # retrieve important variables for saving
      values = this.saveable_values()

      id = this.get("_id")

      rev = this.get("_rev")
      
      # figure out the best way to save to couchdb based on what values are available
      if rev isnt undefined and id isnt undefined
         # id is available and revision so this is a full update
         couchdb.save(id, rev, values, callback)
      else if id isnt undefined
         # id is available but not revision, might be create or update (if ID is deterministic)
         couchdb.save(id, values, callback)
      else
         # no id or revision, so this is a create =)
         couchdb.save(values, callback)

      # validation was successful so return true
      true

   saveable_values: ->
      result = {}

      def = this.getDefinition()

      def.getAttributeNames().forEach (attr) =>
         # don't return any attributes which start with _ (couchdb's magic attributes)
         return if attr[0] is "_"

         # get the attribute definition
         attr_def = def.getAttributeDefinition(attr)

         # if this attribute is not set to save then return now
         return unless attr_def.save

         # retrieve the value and assign it to the result
         result[attr] = this.get(attr)

      result

CouchModel.design = (type, options) ->
   throw "design_version is required" unless "number" is typeof(options.design_version)

   class new_model extends CouchModel
      constructor: (params) ->
         super(params)

   Class.mixin(new_model, ValidatableModel)

   # assign the design version to the model
   new_model.design_version = options.design_version

   # assign the model type to the new model
   new_model.model_type = type

   # install a design document definition
   App.design_documents[type] = 
      version: options.design_version
      views: options.views

   # add a function to retrieve all associated models
   new_model.get = (id, callback) ->
      couchdb.get id, (err, doc) ->
         throw err if err
         callback.call(null, new new_model(doc))

   # add a function to retrieve all models in a view
   new_model.view = (view, params, callback) ->
      couchdb.view "#{type}/#{view}", params, (err, docs) ->
         throw err if err

         models = (new new_model(doc.value) for doc in docs)

         callback.call(null, models)

   # add all attributes
   for attr in (options.attributes || [])
      name = attr.name
      delete attr.name
      Model.attribute(new_model, name, attr)

   # add all computed attributes
   for attr in (options.computed_attributes || [])
      name = attr.name
      delete attr.name
      Model.computedAttribute(new_model, name, attr)

   # add all validations
   for own key, val of (options.validations || {})
      # add function validations (signified by booleans as their values)
      if "boolean" is typeof val and val is true
         ValidatableModel.validate(new_model, key)

      if "object" is typeof val
         ValidatableModel.validate(new_model, key, val)

   # add the magic _id and _ref attribute definitions if not defined
   # also add the type attribute if not defined
   definition = Model.getModelDefinition(new_model)

   attributes = definition.getAttributeNames()

   if attributes.indexOf("_id") is -1
      Model.attribute(new_model, "_id", {save: true})

   if attributes.indexOf("_rev") is -1
      Model.attribute(new_model, "_rev", {save: true})

   if attributes.indexOf("type") is -1
      Model.attribute(new_model, "type", {save: true})

   return new_model

exports.CouchModel = CouchModel