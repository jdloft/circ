exports = window.chat ?= {}

##
# Handles formatting and styling text to be displayed to the user.
#
# Formatting follows these ruels:
# - all messages start with a capital letter
# - messages from the user or to the user have the 'self' style
# - messages from the user are surrounded by parentheses
# - all other messages are presented as is and end in a period
##
class MessageFormatter
  constructor: ->
    @_customStyle = []
    @_nick = undefined
    @clear()

  ##
  # Sets the user's nick name, which is used to determine if the message is from
  # or to the user. This field is not reset when clear() is called.
  # @param {string} nick The user's nick name.
  ##
  setNick: (nick) ->
    @_nick = nick

  ##
  # Sets custom style to be used for all formatted messages. This field is not
  # reset when clear() is called.
  # @param {string} customStyle The style to be set
  ##
  setCustomStyle: (customStyle) ->
    @_customStyle = [customStyle]

  ##
  # Clears the state of the message formatter. Used between formatting different
  # messages.
  ##
  clear: ->
    @_style = []
    @_fromUs = @_toUs = false
    @_message = ''

  ##
  # Sets the message to be formatted.
  # The following can be used as special literals in the message:
  # - '#from' gets replaced by the the nick the message is from.
  # - '#to' gets replaced by the nick the message pertains to.
  # - '#what' gets replaced by what the message is about.
  # @param {string} message
  ##
  setMessage: (message) ->
    @_message = message

  ##
  # Set the context of the message.
  # @param {string=} opt_from The nick the message is from.
  # @param {string=} opt_to The nick the message pertains to.
  # @param {string=} opt_what What the message is about.
  ##
  setContext: (opt_from, opt_to, opt_what) ->
    @_from = opt_from
    @_to = opt_to
    @_what = opt_what
    @_fromUs = @_isOwnNick @_from
    @_toUs = @_isOwnNick @_to

  ##
  # Force the message to be from the user, even if the from field isn't the same
  # as the user's nick.
  # This is useful for the /nick message, when the user's nick has just changed.
  ##
  forceFromUs: ->
    @_fromUs = true

  ##
  # Force the message to be to the user, even if the from field isn't the same
  # as the user's nick.
  # This is useful for the /nick message, when the user's nick has just changed.
  ##
  forceToUs: ->
    @_toUs = true

  ##
  # Returns a message formatted based on the given context.
  # @return {string} Returns the formatted message.
  ##
  format: ->
    return '' unless @_message
    msg = @_message
    msg = msg.replace '#from', if @_fromUs then 'you' else @_from
    msg = msg.replace '#to', if @_toUs then 'you' else @_to
    msg = msg.replace '#what', @_what
    msg = capitalise msg unless @_startsWithNick msg
    if @_fromUs
      msg = "(#{msg})"
    else if msg
      msg = "#{msg}."
    return msg

  ##
  # Returns true if the given message starts with the nick the message pertains
  # to or the nick the message is being sent from.
  ##
  _startsWithNick: (msg) ->
    startsWithToNick = msg.indexOf(@_to) is 0 and not @_toUs
    startsWithFromNick = msg.indexOf(@_from) is 0 and not @_fromUs
    startsWithToNick or startsWithFromNick

  ##
  # Clears the current style and adds the given style.
  # @param {string} style
  ##
  setStyle: (style) ->
    @_style = [style]

  ##
  # Adds the given style.
  # @param {string} style
  ##
  addStyle: (style) ->
    @_style.push style

  ##
  # Returns the style of the message.
  # @param {string} style The combination of the added styles and custom styles.
  # @return {string} A space delimited string of styles to apply to the message.
  ##
  getStyle: ->
    style = @_customStyle.concat @_style
    style.push 'self' if @_fromUs or @_toUs
    return style.join ' '

  ##
  # Returns true if the user's nick equals the given nick.
  # @param nick The nick the check against
  # @return {boolean}
  ##
  _isOwnNick: (nick) ->
    irc.util.nicksEqual @_nick, nick

exports.MessageFormatter = MessageFormatter