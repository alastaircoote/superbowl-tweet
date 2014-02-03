class State2D
    broncoColor: new Chromath("#FF6600")
    seahawkColor: new Chromath("#003399")
    constructor: (shape) ->
        @shape = d3.select(shape)
        setTimeout @raiseUp, 1000 * Math.random()

    setColorProgression: (a,b) =>
        color = new Chromath("#cccccc")
        if a > b then color = color.towards(@seahawkColor, a / (a+b))
        if b > a then color = color.towards(@broncoColor, b / (a+b))
        @shape.style "fill", color.toString()

    raiseUp: (@colorProgA, @colorProgB) =>
        @shape.on "webkitTransitionEnd", @changeColor
        @shape.style {
            "-webkit-transition": "-webkit-transform 0.2s ease-in"
            "-webkit-transform": "perspective(1000) rotateX(90deg)"
        }
    
    changeColor: () =>
        @shape.on "webkitTransitionEnd", null
        @shape.style {
            "-webkit-transition": "none"
            "-webkit-transform": "rotateX(270deg)"
        }
        if @colorProg then @setColorProgression(@colorProgA, @colorProgB)
        setTimeout () =>
            @shape.style {
                "-webkit-transition": "-webkit-transform 0.2s ease-out"
                "-webkit-transform": "perspective(1000) rotateX(360deg)"
            }
        ,1

map.State2D = State2D