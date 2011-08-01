
class window.KeyboardInputHandler
   constructor: ->
      jQuery(document).bind "keydown", (e) =>
         if e.keyCode is 8 or e.which is 8
            game_screen.backspace()
            return false         

         return true

      jQuery(document).bind "keypress", (e) =>
         char = String.fromCharCode(e.charCode)

         # check if the given character is a non printable character
         if /[\x00-\x1F]/.test(char)
            return this.commandKey(e.keyCode || e.which)
         else
            return this.textKey(char)


   commandKey: (keyCode) ->
      switch keyCode
         # enter key
         when 13 then game_screen.submitInput()

         # backspace key
         when 8 then game_screen.backspace()

         # meta keys
         when 91, 92, 93
            return true

         # function keys (use default behavior)
         when 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123
            return true

         # caps lock, scroll lock
         when 144, 145
            return true

         else return false
      
      return false

   textKey: (char) ->
      game_screen.appendInput(char)
      return false
