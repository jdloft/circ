// Generated by CoffeeScript 1.4.0
(function() {
  "use strict";
  var AutoComplete, exports,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  var exports = window;

  /*
   * Takes a string and replaces a word with its completion based on the cursor position.
   * Currently only supports completion of nicks in the current window.
  */


  AutoComplete = (function() {
    /*
       * Inserted after a nick which is at the start of the input is auto-completed.
       * @const
    */

    var Completion;

    AutoComplete.COMPLETION_SUFFIX = ':';

    function AutoComplete() {
      this._getPossibleCompletions = __bind(this._getPossibleCompletions, this);
      this._completionFinder = new CompletionFinder;
    }

    /*
       * Set the context from which the list of nicks can be generated.
       * @param {{currentWindow: {target: string, conn: Object}}} context
    */


    AutoComplete.prototype.setContext = function(context) {
      this._context = context;
      return this._completionFinder.setCompletionGenerator(this._getPossibleCompletions);
    };

    /*
       * Returns a list of possible auto-completions in the current channel.
       * @return {Array.<Completion>}
    */


    AutoComplete.prototype._getPossibleCompletions = function() {
      var completions;
      completions = [];
      completions = completions.concat(this._getCommandCompletions());
      completions = completions.concat(this._getNickCompletions());
      return completions;
    };

    /*
       * Returns a list of visible commands.
       * @return {Array.<Completion>}
    */


    AutoComplete.prototype._getCommandCompletions = function() {
      var cmd, commandName, commandNames, commandObj, commands, _i, _len, _results;
      commands = this._context.userCommands.getCommands();
      commandNames = [];
      for (commandName in commands) {
        commandObj = commands[commandName];
        if (commandObj.category === 'hidden') {
          continue;
        }
        commandNames.push(commandName);
      }
      commandNames.sort();
      _results = [];
      for (_i = 0, _len = commandNames.length; _i < _len; _i++) {
        cmd = commandNames[_i];
        _results.push(new Completion(cmd, Completion.CMD));
      }
      return _results;
    };

    /*
       * Returns a list of nicks in the current channel.
       * @return {Array.<Completion>}
    */


    AutoComplete.prototype._getNickCompletions = function() {
      var chan, completions, nick, nicks, norm, ownNick, _ref, _ref1;
      chan = this._context.currentWindow.target;
      nicks = (_ref = this._context.currentWindow.conn) != null ? (_ref1 = _ref.irc.channels[chan]) != null ? _ref1.names : void 0 : void 0;
      if (nicks != null) {
        ownNick = this._context.currentWindow.conn.irc.nick;
        completions = [];
        for (norm in nicks) {
          nick = nicks[norm];
          if (nick !== ownNick) {
            completions.push(new Completion(nick, Completion.NICK));
          }
        }
        return completions;
      }
      return [];
    };

    /*
       * Returns the passed in text, with the current stub replaced with its
       * completion.
       * @param {string} text The text the user has input.
       * @param {number} cursor The current position of the cursor.
    */


    AutoComplete.prototype.getTextWithCompletion = function(text, cursor) {
      var completion, textWithCompletion;
      this._text = text;
      this._cursor = cursor;
      if (this._previousText !== this._text) {
        this._completionFinder.reset();
      }
      this._previousCursor = this._cursor;
      if (!this._completionFinder.hasStarted) {
        this._extractStub();
      }
      completion = this._getCompletion();
      textWithCompletion = this._preCompletion + completion + this._postCompletion;
      this._updatedCursorPosition = this._preCompletion.length + completion.length;
      this._previousText = textWithCompletion;
      return textWithCompletion;
    };

    AutoComplete.prototype.getUpdatedCursorPosition = function() {
      var _ref;
      return (_ref = this._updatedCursorPosition) != null ? _ref : 0;
    };

    /*
       * Returns the completion for the current stub with the completion suffix and
       * or space after.
    */


    AutoComplete.prototype._getCompletion = function() {
      var completion;
      completion = this._completionFinder.getCompletion(this._stub);
      if (completion === CompletionFinder.NONE) {
        return this._stub;
      }
      return completion.getText() + completion.getSuffix(this._preCompletion.length);
    };

    /*
       * Finds the stub by looking at the cursor position, then finds the text before
       * and after the stub.
    */


    AutoComplete.prototype._extractStub = function() {
      var preStubEnd, stubEnd;
      stubEnd = this._findNearest(this._cursor - 1, /\S/);
      if (stubEnd < 0) {
        stubEnd = 0;
      }
      preStubEnd = this._findNearest(stubEnd, /\s/);
      this._preCompletion = this._text.slice(0, preStubEnd + 1);
      this._stub = this._text.slice(preStubEnd + 1, +stubEnd + 1 || 9e9);
      return this._postCompletion = this._text.slice(stubEnd + 1);
    };

    /*
       * Searches backwards until the regex matches the current character.
       * @return {number} The position of the matched character or -1 if not found.
    */


    AutoComplete.prototype._findNearest = function(start, regex) {
      var i, _i;
      for (i = _i = start; start <= 0 ? _i <= 0 : _i >= 0; i = start <= 0 ? ++_i : --_i) {
        if (regex.test(this._text[i])) {
          return i;
        }
      }
      return -1;
    };

    /*
       * Simple storage class for completions which stores the completion text
       * and type of completion.
    */


    Completion = (function() {
      /*
           * Completions can either be commands or nicks.
      */

      Completion.CMD = 0;

      Completion.NICK = 1;

      Completion.COMPLETION_SUFFIX = ':';

      function Completion(_text, _type) {
        this._text = _text;
        this._type = _type;
        if (this._type === Completion.CMD) {
          this._text = '/' + this._text;
        }
      }

      Completion.prototype.getText = function() {
        return this._text;
      };

      Completion.prototype.getType = function() {
        return this._type;
      };

      Completion.prototype.getSuffix = function(preCompletionLength) {
        if (this._type === Completion.NICK && preCompletionLength === 0) {
          return Completion.COMPLETION_SUFFIX + ' ';
        }
        return ' ';
      };

      Completion.prototype.toString = function() {
        return this.getText();
      };

      return Completion;

    })();

    return AutoComplete;

  }).call(this);

  exports.AutoComplete = AutoComplete;

}).call(this);