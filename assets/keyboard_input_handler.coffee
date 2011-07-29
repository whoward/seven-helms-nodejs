
class window.KeyboardInputHandler
   constructor: ->
      jQuery(document).bind "keydown", (e) =>
         this.commandKey(e.keyCode || e.which)

      jQuery(document).bind "keypress", (e) =>
         char = String.fromCharCode(e.charCode)
         this.textKey(char)


   commandKey: (keyCode) ->
      switch keyCode
         # enter key
         when 13 then screen.submitInput()

         # backspace key
         when 8 then screen.backspace()

         else return true
      
      return false

   textKey: (char) ->
      screen.appendInput(char)
