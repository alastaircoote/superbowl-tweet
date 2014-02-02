// Generated by CoffeeScript 1.6.2
(function() {
  var State2D,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  State2D = (function() {
    State2D.prototype.broncoColor = new Chromath("#FF6600");

    State2D.prototype.seahawkColor = new Chromath("#003399");

    function State2D(shape) {
      this.changeColor = __bind(this.changeColor, this);
      this.raiseUp = __bind(this.raiseUp, this);
      this.setColorProgression = __bind(this.setColorProgression, this);      this.shape = d3.select(shape);
      setTimeout(this.raiseUp, 1000 * Math.random());
    }

    State2D.prototype.setColorProgression = function(i) {
      return this.shape.style("fill", this.broncoColor.towards(this.seahawkColor, i).toString());
    };

    State2D.prototype.raiseUp = function() {
      this.shape.on("webkitTransitionEnd", this.changeColor);
      return this.shape.style({
        "-webkit-transition": "-webkit-transform 0.2s ease-in",
        "-webkit-transform": "perspective(1000) rotateX(90deg)"
      });
    };

    State2D.prototype.changeColor = function() {
      var _this = this;

      this.shape.on("webkitTransitionEnd", null);
      this.shape.style({
        "-webkit-transition": "none",
        "-webkit-transform": "rotateX(270deg)"
      });
      return setTimeout(function() {
        return _this.shape.style({
          "-webkit-transition": "-webkit-transform 0.2s ease-out",
          "-webkit-transform": "perspective(1000) rotateX(360deg)"
        });
      }, 1);
    };

    return State2D;

  })();

  map.State2D = State2D;

}).call(this);
