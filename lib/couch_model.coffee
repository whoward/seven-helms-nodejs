Class = require("./class")
Model = require("./model/model").Model
ValidatableModel = require("./validatable_model/model").ValidatableModel

class CouchModel
   constructor: (params) ->
      Class.constructMixins(this)
      this.massAssignValues(params)

   save: ->
      return this.validate()

CouchModel.design = (options) ->
   class new_model extends CouchModel
      constructor: (params) ->
         super(params)

   Class.mixin(new_model, ValidatableModel)

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

   # add the magic _id and _ref variable definitions if not defined
   definition = Model.getModelDefinition(new_model)

   attributes = definition.getAttributeNames()

   if attributes.indexOf("_id") is -1
      Model.attribute(new_model, "_id")

   if attributes.indexOf("_ref") is -1
      Model.attribute(new_model, "_ref")

   return new_model

exports.CouchModel = CouchModel