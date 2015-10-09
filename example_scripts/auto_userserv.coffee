setName 'auto_amzn'
setDescription 'Auto-login for sirc.amazon.com internal IRC servers'

send 'hook_message', 'privmsg'

serverCreds = {}

loadFromStorage()

loginSucceeded = (e) ->
  e.type is 'system' and e.name is 'loaded' and e.args[0]

@onMessage = (e) ->
  debugOutput e
  if loginSucceeded(e)
    updatePasswords e.args[0]
  else if e.type is 'message' and e.name is 'privmsg'
    handlePrivateMessage e
  else
    propagate e

handlePrivateMessage = (e) ->
  [source, message] = e.args

  if not source.toLowerCase() is 'userserv'
    return propagate e

  if shouldAutoIdentify e.context, message
    propagate e

    return autoIdentify e.context, message

  if userServPasswordIsVisible message
    propagate e, 'none'

    snoopPassword e.context, message

    return hideUserServPassword e

  propagate e

shouldAutoIdentify = (context, message) ->
  haveCredsFor context.server

haveCredsFor = (server) ->
  serverCreds.hasOwnProperty server

autoIdentify = (context, message) ->
  creds = serverCreds[context.server]

  send context, 'message', 'notice', 'Automatically identifying with UserServ...'
  send context, 'command', 'raw', 'PRIVMSG', 'userserv', "login #{creds}"

userServPasswordIsVisible = (message) ->
  [cmd, user, pass] = message.split ' '

  pass and cmd.toLowerCase is 'login'

snoopPassword = (context, message) ->
  [cmd, user, pass] = message.split ' '
  serverCreds[context.server] = "#{user} #{pass}"
  saveToStorage serverCreds

hideUserServPassword = (e) ->
  words = e.args[1].split ' '
  words[1] = '[hidden]'
  e.args[1] = words.join ' '
  sendEvent e

# This doesn't seem right...
updatePasswords = (loadedPasswords) ->
  for server in loadedPasswords
    if not serverCreds[server]
      serverCreds[server] = loadedPasswords[server]
  
debugOutput = (output...) ->
  if arguments.length is 1
    output = output[0]

  send 'debug', 'message', 'notice',
    '[DEBUG]: ' + JSON.stringify output
