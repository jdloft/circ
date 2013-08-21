// Generated by CoffeeScript 1.4.0
(function() {
  "use strict";
  var Timer, exports;

  var exports = window;

  /*
   * Utility class for determining the time between events.
  */


  Timer = (function() {

    function Timer() {}

    /*
       * Maps events to their timing information.
    */


    Timer.prototype._events = {};

    /*
       * Mark the start time of an event.
       * @param {string} name The name of the event.
    */


    Timer.prototype.start = function(name) {
      return this._events[name] = {
        startTime: this._getCurrentTime()
      };
    };

    /*
       * Destroy the event and return the elapsed time.
       * @param {string} name The name of the event.
    */


    Timer.prototype.finish = function(name) {
      var time;
      time = this.elapsed(name);
      delete this._events[name];
      return time;
    };

    /*
       * Returns the elapsed time..
       * @param {string} name The name of the event.
    */


    Timer.prototype.elapsed = function(name) {
      if (!this._events[name]) {
        return 0;
      }
      return this._getCurrentTime() - this._events[name].startTime;
    };

    Timer.prototype._getCurrentTime = function() {
      return new Date().getTime();
    };

    return Timer;

  })();

  exports.Timer = Timer;

}).call(this);