`// auto_amzn v0.0.1`

setName 'auto_amzn'
setDescription 'Auto-login for sirc.amazon.com internal IRC servers'

send 'hook_message', 'privmsg'

serverCreds = {}
identified = {}

loadFromStorage()

# This refers to IRC server login success, not userserv identification
loginSucceeded = (e) ->
  didIt = e.type is 'system' and e.name is 'loaded' and e.args[0]
  console.log 'loginSucceeded: ', e.type, e.name, e.args[0], didIt
  didIt

@onMessage = (e) ->
  console.log 'onMessage ', e

  if loginSucceeded e
    updateCreds e.args[0]

    autoIdentify e.context if serverCreds[e.context.server]
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

    return autoIdentify e.context

  if userServPasswordIsVisible message
    propagate e, 'none'

    snoopPassword e.context, message

    return hideUserServPassword e

  propagate e

shouldAutoIdentify = (context, message) ->
  server = context.server
  ident = not identified[server] and serverCreds[server]
  identified[server] = true
  return ident

autoIdentify = (context) ->
  creds = serverCreds[context.server]

  send context, 'message', 'notice', 'Automatically identifying with UserServ...'
  send context, 'command', 'raw', 'PRIVMSG', 'userserv', "login", creds.split ' '

userServPasswordIsVisible = (message) ->
  [cmd, user, pass] = message.split ' '

  pass and cmd.toLowerCase() is 'login'

snoopPassword = (context, message) ->
  [cmd, user, pass] = message.split ' '
  serverCreds[context.server] = "#{user} #{pass}"
  saveToStorage serverCreds

hideUserServPassword = (e) ->
  words = e.args[1].split ' '
  words[1] = '[hidden]'
  e.args[1] = words.join ' '
  sendEvent e

# Called after connecting to server
updateCreds = (loadedPasswords) ->
  console.log 'updateCreds: ', serverCreds, loadedPasswords
  for server in loadedPasswords
    if not serverCreds[server]
      serverCreds[server] = loadedPasswords[server]
  
