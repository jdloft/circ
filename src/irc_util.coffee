exports = (window.irc ?= {}).util ?= {}

exports.parseCommand = (data) ->
  str = data.toString('utf8')
  parts = ///
    ^
    (?: : ([^\x20]+?) \x20)?        # prefix
    ([^\x20]+?)                     # command
    ((?:\x20 [^\x20:] [^\x20]*)+)?  # params
    (?:\x20:(.*))?                  # trail
    $
  ///.exec(str)
  throw new Error("invalid IRC message: #{data}") unless parts
  # could do more validation here...
  # prefix = servername | nickname((!user)?@host)?
  # command = letter+ | digit{3}
  # params has weird stuff going on when there are 14 arguments

  # trim whitespace
  if parts[3]?
    parts[3] = parts[3].slice(1).split(/\x20/)
  else
    parts[3] = []
  parts[3].push(parts[4]) if parts[4]?
  {
    prefix: parts[1]
    command: parts[2]
    params: parts[3]
  }

exports.parsePrefix = (prefix) ->
  p = /^([^!]+?)(?:!(.+?)(?:@(.+?))?)?$/.exec(prefix)
  { nick: p[1], user: p[2], host: p[3] }

exports.makeCommand = (cmd, params...) ->
  _params = if params and params.length > 0
    if !params[0...params.length-1].every((a) -> !/^:|\x20/.test(a))
      throw new Error("some non-final arguments had spaces or initial colons in them")
    if /^:|\x20/.test(params[params.length-1])
      params[params.length-1] = ':'+params[params.length-1]
    ' ' + params.join(' ')
  else
    ''
  cmd + _params + "\x0d\x0a"

exports.randomName = (length = 10) ->
  chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  (chars[Math.floor(Math.random() * chars.length)] for x in [0...length]).join('')

exports.normaliseNick = (nick) ->
  nick.toLowerCase().replace(/[\[\]\\]/g, (x) -> ('[':'{', ']':'}', '|':'\\')[x])

exports.nicksEqual = (a, b) -> exports.normaliseNick(a) == exports.normaliseNick(b)

exports.toSocketData = (str, cb) ->
  string2ArrayBuffer str, (ab) ->
    cb ab

exports.fromSocketData = (ab, cb) ->
  arrayBuffer2String ab, cb

exports.emptySocketData = -> new ArrayBuffer(0)

exports.concatSocketData = (a, b) ->
  concatArrayBuffers(a, b)

concatArrayBuffers = (a, b) ->
  result = new ArrayBuffer a.byteLength + b.byteLength
  resultView = new Uint8Array result
  resultView.set new Uint8Array a
  resultView.set new Uint8Array(b), a.byteLength
  result

string2ArrayBuffer = (string, callback) ->
  blob = new Blob [string]
  f = new FileReader()
  f.onload = (e) ->
    callback(e.target.result)
  f.readAsArrayBuffer(blob)

arrayBuffer2String = (buf, callback) ->
  blob = new Blob [new DataView buf]
  f = new FileReader()
  f.onload = (e) ->
    callback(e.target.result)
  f.readAsText(blob)