$(document).ready(function() {
   var webSocket = io.connect('http://' + window.location.host)

   webSocket.on('connect', function() {
      $('#messages').append('<li>Connected to the server.</li>');
   });

   webSocket.on('message', function(message) {
      $('#messages').append('<li>' + message + '</li>');
   });

   webSocket.on('disconnect', function() {
      $('#messages').append('<li>Disconnected from the server.</li>');
   });

   var input = "";

   // we must use keydown since it is the only one which properly intercepts backspace
   $(document).bind("keydown", function(e) {
      var code = (e.keyCode ? e.keyCode : e.which) ;

      switch(code) {
         case 13: // enter key
            webSocket.emit("message", input);
            input = "";
            break;

         case 8: // backspace key
            input = input.slice(0, input.length - 1);
            break;
         
         default:
            return true;
      }

      $("#console").html("> " + input + "_");
      return false;
   });

   $(document).bind("keypress", function(e) {
      input += String.fromCharCode(e.charCode);
      $("#console").html("> " + input + "_");
   });
});
