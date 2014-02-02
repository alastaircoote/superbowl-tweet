width = 960
height = 500
projection = d3.geo.albersUsa()
    .scale(1000)
    .translate([width / 2, height / 2]);

path = d3.geo.path()
    .projection(projection);

svg = d3.select("body").append("svg")
    .style("display","none")
    .attr("width", width)
    .attr("height", height);

states = null

d3.json "/topo-states.json", (error, us) ->
    console.log topojson.feature(us, us.objects["states"]).features.map (f) -> f.properties.name
    svg.selectAll(".county")
    .data(topojson.feature(us, us.objects["states"]).features)
    .enter()
        .append("path")
        .attr("class", "county")
        .attr("statename",(s) -> s.properties.name.toLowerCase())
        .attr("d",path)

    states = map.addShapes(svg.selectAll(".county"))
    svg.remove()
    console.log states
    doDataGrab()

oldLastTen = []
lastTen = []

stateData = null

doDataGrab = () ->
    d3.json "/data/data.json", (error, data) ->
        lastTen = oldLastTen.concat(data.lastTenSecs)
        oldLastTen = data.lastTenSecs
        
        setTimeout doDataGrab, 1000*10

        if stateData == null
            console.log "newdata", data.stateTotals
            for state, totals of data.stateTotals
                stateName = state.toLowerCase()
                if stateName == "colorado" then console.log totals.broncos, totals.seahawks, totals.broncos / (totals.broncos + totals.seahawks)
                console.log stateName
                if !totals.broncos then states[stateName].setColorProgression 1
                else if !totals.seahawks then states[stateName].setColorProgression 0
                else states[stateName].setColorProgression totals.seahawks / (totals.broncos + totals.seahawks)



lastTime = Date.now() - 10 * 1000
doAnimate = () ->
    timeToCheck = Date.now() - 10 * 1000

    newTweets = lastTen.filter (t) -> t.saved_at > lastTime && t.saved_at < timeToCheck
    lastTime = timeToCheck
    setTimeout doAnimate, 100

    for tweet in newTweets
        targetState = tweet.state.toLowerCase()
        states[targetState].raiseUp()

doAnimate()



