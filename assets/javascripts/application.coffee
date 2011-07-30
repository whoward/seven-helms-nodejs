jQuery(document).ready ->
   window.game_screen = new GameScreen("body")
   window.input_handler = new KeyboardInputHandler()
   window.connection = new Connection()
