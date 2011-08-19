jQuery(document).ready ->
   window.game_screen = new GameScreen("body")
   window.input_handler = new KeyboardInputHandler()
   window.connection = new Connection()
   window.input_parser = new InputParser()
   window.login_dialog = new LoginDialog("body")
   window.registration_dialog = new RegistrationDialog("body")