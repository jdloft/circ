`// auto_amzn v0.0.1`

setName 'auto_amzn'
setDescription 'Auto-login for sirc.amazon.com internal IRC servers'

eventsToWatch =
  hook_message: [ 'privmsg' ]
  hook_server: [ 'connect' ]
###
  hook_server: """
      connect disconnect joined names parted nick
    """.split ' '
  hook_message: """
      topic topic_info list join part kick nick mode user_mode quit disconnect
      connect privmsg breakgroup error system notice welcome other nickinuse
      away kill socket_error
    """.split ' '
  hook_command: """
      nick server join part leave close invite win debug say list me quit names
      clear help hotkeys raw quote install uninstall scripts topic kick mode op
      deop voice devoice away back msg whois swhois whowas who about
      join-server make-server network-info stop-server autostart query kill
      version ignore unignore theme next-server next-room previous-room reply
      image suspend-notifications
    """.split ' '
###

for hook, names of eventsToWatch
  send hook, name for name in names

# retrieved from CIRC script framework at server connect
serverCreds = {}

# Not quite sure how this works yet
loadFromStorage()

@onMessage = (e) ->
  console.log 'onMessage ', e

  if loggingIn e
    return handleLogin e

  propagate e

  if e.type is 'system' and e.name is 'loaded'
    dataLoaded e

  if e.type is 'server' and e.name is 'connect'
    autoAuth e.context

loggingIn = (e) ->
  {type, name, context, args} = e
  if type is 'message' and name is 'privmsg' and args and args[1]
    channel = context.channel.toLowerCase()
    cmd = args[1].trim().split(' ')[0].toLowerCase()

    return channel is 'userserv' and cmd is 'login'

handleLogin = (e) ->
  propagate e, 'none'
  words = e.args[1].trim().split ' '
  server = e.context.server

  serverCreds[server] = words[1..2].join ' '
  saveToStorage serverCreds

  words[2] = '[hidden]'
  e.args[1] = words.join ' '
  sendEvent e

  return

autoAuth = (context) ->
  server = context.server
  creds = serverCreds[server]

  if creds
    msg = '"login ' + creds + '"'
    console.log "Attempt auth with #{msg}"
    send context, 'message', 'notice', 'Automatically identifying with UserServ...'
    send context, 'command', 'raw', 'PRIVMSG', 'userserv', msg
  else
    console.log 'No creds for ' + server, serverCreds

dataLoaded = (e) ->
  saved = e.args[0]

  if saved
    for server, creds of saved
      serverCreds[server] = creds
    console.log 'dataLoaded: ', serverCreds
  else
    console.log 'serverConnected - no credentials known'

