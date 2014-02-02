svgholder = document.getElementsByClassName("svgholder")[0]
hasWebGL = document.createElement("canvas").getContext("webgl") != null

width = svgholder.clientWidth
height = svgholder.clientWidth * 0.6

if hasWebGL
    width = 960
    height = 500

projection = d3.geo.albersUsa()
    .scale(if !hasWebGL then 1000 / (760 / width) else 1000)
    .translate([width / 2, height / 2]);

path = d3.geo.path()
    .projection(projection);

svg = d3.select(".svgholder")
    
    .append("svg")
    .style("-webkit-transform","rotate3d(-1,1,0,-30deg)")
    #.style("display","none")
    .attr("width", width)
    .attr("height", height);

$(window).on "resize", () ->
    if !hasWebGL
        window.location.reload()

states = null

doSvgDraw = () ->
    svg.selectAll(".county")
    .data(map.stateShapes)
    .enter()
        .append("path")
        .attr("class", "county")
        .attr("statename",(s) -> s.properties.STATE_NAME.toLowerCase())
        .attr("d",path)

    if hasWebGL
        map.create3DView(svg.selectAll(".county"))

        svg.remove()
    else
        map.create2DView(svg.selectAll(".county"))


d3.json "/topo-states.json", (error, us) ->

    map.stateShapes = topojson.feature(us, us.objects["usa_state_shapefile"]).features
    doSvgDraw()
    doDataGrab()

oldLastTen = []
lastTen = []

stateData = null

maxTweets = null

setStateDisplay = () ->

    stateArray = []
    for key, data of stateData
        stateArray.push {
            name: key
            broncos: data.broncos
            seahawks: data.seahawks
        }
    stateArray.sort (a,b) ->
        (b.broncos + b.seahawks) - (a.broncos + a.seahawks)

    maxTweets = stateArray[0].broncos
    if stateArray[0].seahawks > maxTweets then maxTweets = stateArray[0].seahawks

    lis = []
    for state in stateArray
        li = $("<li>")
        h3 = $("<h3>").html(state.name)
        
        ident = state.name.toLowerCase().replace(/\s/g,"_")

        shBar = $("<div class='bar seahawks #{ident}'/>")
        shBar.css "width", Math.round(state.seahawks / maxTweets * 100) + "%"

        brBar = $("<div class='bar broncos'/>")
        brBar.css "width", Math.round(state.broncos/ maxTweets * 100) + "%"

        li.append h3, shBar, brBar

        lis.push li

    $("#statesdisplay").empty().append lis

doDataGrab = () ->
    d3.json "/data/data.json?dt=" + new Date().valueOf(), (error, data) ->
        console.log error,data
        lastTen = oldLastTen.concat(data.lastTenSecs)
        oldLastTen = data.lastTenSecs
        
        setTimeout doDataGrab, 1000*10

        if stateData == null
            console.log "newdata", data.stateTotals
            for state, totals of data.stateTotals
                stateName = state.toLowerCase()
                if stateName == "colorado" then console.log totals.broncos, totals.seahawks, totals.broncos / (totals.broncos + totals.seahawks)

                if !totals.broncos then map.states[stateName].setColorProgression 1
                else if !totals.seahawks then map.states[stateName].setColorProgression 0
                else map.states[stateName].setColorProgression totals.seahawks / (totals.broncos + totals.seahawks)

            stateData = data.stateTotals
            console.log stateData
            setStateDisplay()



lastTime = Date.now() - 10 * 1000
doAnimate = () ->
    timeToCheck = Date.now() - 10 * 1000

    newTweets = lastTen.filter (t) -> t.saved_at > lastTime && t.saved_at < timeToCheck
    lastTime = timeToCheck
    setTimeout doAnimate, 100

    for tweet in newTweets
        targetState = tweet.state.toLowerCase()
        map.states[targetState].raiseUp()
        if tweet.keyword

            stateData[tweet.state][tweet.keyword]++
            if stateData[tweet.state][tweet.keyword] > maxTweets
                #reset whole display
                setStateDisplay()
            else
                ident = targetState.replace(/\s/g,"_")
                $(".#{ident}.#{tweet.keyword}").css "width", Math.round(state[keyword] / maxTweets * 100) + "%"
            console.log "upped #{tweet.keyword} in #{tweet.state}"

doAnimate()

$("#tweetBroncos").on "click", () -> map.sendTweet "Broncos"
$("#tweetBroncos").on "click", () -> map.sendTweet "Seahawks"
