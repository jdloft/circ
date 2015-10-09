// Generated by CoffeeScript 1.10.0
var autoIdentify, debugOutput, handlePrivateMessage, haveCredsFor, hideUserServPassword, loginSucceeded, serverCreds, shouldAutoIdentify, snoopPassword, updatePasswords, userServPasswordIsVisible,
  slice = [].slice;

setName('auto_amzn');

setDescription('Auto-login for sirc.amazon.com internal IRC servers');

send('hook_message', 'privmsg');

serverCreds = {};

loadFromStorage();

loginSucceeded = function(e) {
  return e.type === 'system' && e.name === 'loaded' && e.args[0];
};

this.onMessage = function(e) {
  debugOutput(e);
  if (loginSucceeded(e)) {
    return updatePasswords(e.args[0]);
  } else if (e.type === 'message' && e.name === 'privmsg') {
    return handlePrivateMessage(e);
  } else {
    return propagate(e);
  }
};

handlePrivateMessage = function(e) {
  var message, ref, source;
  ref = e.args, source = ref[0], message = ref[1];
  if (!source.toLowerCase() === 'userserv') {
    return propagate(e);
  }
  if (shouldAutoIdentify(e.context, message)) {
    propagate(e);
    return autoIdentify(e.context, message);
  }
  if (userServPasswordIsVisible(message)) {
    propagate(e, 'none');
    snoopPassword(e.context, message);
    return hideUserServPassword(e);
  }
  return propgate(e);
};

shouldAutoIdentify = function(context, message) {
  return haveCredsFor(context.server);
};

haveCredsFor = function(server) {
  return serverCreds.hasOwnProperty(server);
};

autoIdentify = function(context, message) {
  var creds;
  creds = serverCreds[context.server];
  send(context, 'message', 'notice', 'Automatically identifying with UserServ...');
  return send(context, 'command', 'raw', 'PRIVMSG', 'userserv', "login " + creds);
};

userServPasswordIsVisible = function(message) {
  var cmd, pass, ref, user;
  ref = message.split(' '), cmd = ref[0], user = ref[1], pass = ref[2];
  return words.length === 3 && words[0].toLowerCase === 'login';
};

snoopPassword = function(context, message) {
  var cmd, pass, ref, user;
  ref = message.split(' '), cmd = ref[0], user = ref[1], pass = ref[2];
  serverCreds[context.server] = user + " " + pass;
  return saveToStorage(serverCreds);
};

hideUserServPassword = function(e) {
  var words;
  words = e.args[1].split(' ');
  words[1] = '[hidden]';
  e.args[1] = words.join(' ');
  return sendEvent(e);
};

updatePasswords = function(loadedPasswords) {
  var i, len, results, server;
  results = [];
  for (i = 0, len = loadedPasswords.length; i < len; i++) {
    server = loadedPasswords[i];
    if (!serverCreds[server]) {
      results.push(serverCreds[server] = loadedPasswords[server]);
    } else {
      results.push(void 0);
    }
  }
  return results;
};

debugOutput = function() {
  var output;
  output = 1 <= arguments.length ? slice.call(arguments, 0) : [];
  if (arguments.length === 1) {
    output = output[0];
  }
  return send('debug', 'message', 'notice', '[DEBUG]: ' + JSON.stringify(output));
};
