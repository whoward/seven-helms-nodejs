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

         case 112: // Function Keys F1->F12
         case 113:
         case 114:
         case 115:
         case 116:
         case 117:
         case 118:
         case 119:
         case 120:
         case 121:
         case 122:
         case 123:
            return true;

         case 188: // comma key
            input += ",";
         
         case 189: // dash key
            input += "-";

         case 190: // period key
            input += ".";

         case 191: // forward slash key
            input += "/";

         case 219: // open bracket key
            input += "(";

         case 220: // backslash key
            input += "\\";

         case 221: // close bracket key
            input += ")";

         case 222: // single quote key
            input += "'";



         default: // any valid unhandled keyboard key
            // if in the string character range and the shift key is not pressed, then downcase the letter
            if(65 <= code && code <= 90 && !e.shiftKey) {
               code = code + 32;
            }

            // and append it to the input
            input += String.fromCharCode(code);
      }

      $("#console").html("> " + input + "_");

      // consider also: tab=9, shift=16, ctrl=17, alt=18, pause/break=19 capslock=
      // http://www.cambiaresearch.com/c4/702b8cd1-e5b0-42e6-83ac-25f0306e3e25/javascript-char-codes-key-codes.aspx
      return false;
   });
});
