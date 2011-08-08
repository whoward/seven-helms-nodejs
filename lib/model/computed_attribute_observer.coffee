
class exports.ComputedAttributeObserver
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