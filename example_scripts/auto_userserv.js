setName('auto_userserv');
setDescription('hides UserServ password and automatically identifies on startup');

send('hook_message', 'privmsg');
loadFromStorage();

// Keeps track of the last UserServ password used in each server.
var serverPasswords = {};

this.onMessage = function(e) {
  if (e.type == 'system' && e.name == 'loaded' && e.args[0]) {
    updatePasswords(e.args[0]);
  } else if (e.type == 'message' && e.name == 'privmsg') {
    handlePrivateMessage(e);
  } else {
    propagate(e);
  }
};

var handlePrivateMessage = function(event) {
  var source = event.args[0];
  var message = event.args[1];

  if (source.toLowerCase() != 'userserv') {
    return propagate(event);
  } 
  
  if (shouldAutoIdentify(event.context, message)) {
    propagate(event);

    return autoIdentify(event.context, message);
  } 
  
  if (userServPasswordIsVisible(message)) {
    propagate(event, 'none');
    snoopPassword(event.context, message);

    return hideUserServPassword(event);
  }

  propagate(event);
};

var shouldAutoIdentify = function(context, message) {
  return message.indexOf('username is registered') >= 0 &&
      serverPasswords[context.server];
};

var autoIdentify = function(context, message) {
  var pw = serverPasswords[context.server];

  send(context, 'message', 'notice', 'Automatically identifying with UserServ...');
  send(context, 'command', 'raw', 'PRIVMSG', 'UserServ', '"login ', pw + '"');
};

var userServPasswordIsVisible = function(message) {
  var words = message.split(' ');
  var cmd = words[0];
  var user = words[1];
  var pass = words[2];

  return words.length == 3 && words[0].toLowerCase() == 'login';
};

var snoopPassword = function(context, message) {
  var words = message.split(' ');
  var password = words[1] + ' ' + words[2];

  serverPasswords[context.server] = password;
  saveToStorage(serverPasswords);
};

var hideUserServPassword = function(event) {
  var words = event.args[1].split(' ');

  words[1] = getHiddenPasswordText(words[1].length);
  event.args[1] = words.join(' ');
  sendEvent(event);
};

var getHiddenPasswordText = function(length) {
  var hiddenPasswordText = '';

  for (var i = 0; i < length; i++) {
    hiddenPasswordText += '*';
  }

  return hiddenPasswordText;
};

var updatePasswords = function(loadedPasswords) {
  for (var server in loadedPasswords) {
    if (!serverPasswords[server]) {
      serverPasswords[server] = loadedPasswords[server];
    }
  }
};
