
exports.DesignDocuments = {}

exports.DesignDocuments["seven-helms"] =
   version: 1
   validate_doc_update: (doc, prev_doc, user_context) ->
      # if being deleted the new doc should not equal the previous doc
      return if doc._deleted

      # all documents must have the type attribute
      throw "type is required" if not doc.type
