
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
         when 13 then game_screen.submitInput()

         # backspace key
         when 8 then game_screen.backspace()

         else return true
      
      return false

   textKey: (char) ->
      game_screen.appendInput(char)
