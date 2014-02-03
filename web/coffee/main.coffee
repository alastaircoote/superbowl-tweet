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
        aTop = if a.broncos > a.seahawks then a.broncos else a.seahawks
        bTop = if b.broncos > b.seahawks then b.broncos else b.seahawks
        bTop - aTop

    maxTweets = stateArray[0].broncos + 200
    if stateArray[0].seahawks > maxTweets then maxTweets = stateArray[0].seahawks + 200

    lis = []
    for state in stateArray
        li = $("<li>")
        h3 = $("<h3>").html(state.name)
        
        ident = state.name.toLowerCase().replace(/\s/g,"_")

        shBar = $("<div class='bar seahawks #{ident}'/>")
        shBar.css "width", (state.seahawks / maxTweets * 100) + "%"

        brBar = $("<div class='bar broncos #{ident}'/>")
        brBar.css "width", (state.broncos/ maxTweets * 100) + "%"

        li.append h3, shBar, brBar

        lis.push li

    $("#statesdisplay").empty().append lis

doDataGrab = () ->
    setTimeout doDataGrab, 1000*5
    d3.json "/data/data.json?dt=" + new Date().valueOf(), (error, data) ->
        lastTen = oldLastTen.concat(data.lastTenSecs)
        oldLastTen = data.lastTenSecs
        
    
        if stateData == null
            for state, totals of data.stateTotals
                stateName = state.toLowerCase()
                
                #if !totals.broncos then map.states[stateName].setColorProgression 1
                #else if !totals.seahawks then map.states[stateName].setColorProgression 0
                map.states[stateName].setColorProgression totals.seahawks, totals.broncos

            stateData = data.stateTotals
            setStateDisplay()
            #lastTime = lastTen[0].saved_at - 1
            doAnimate()



lastTime = Date.now() - 10 * 1000
doAnimate = () ->
    timeToCheck = Date.now() - 10 * 1000

    newTweets = lastTen.filter (t) -> t.saved_at > lastTime && t.saved_at < timeToCheck
    lastTime = timeToCheck
    setTimeout doAnimate, 100



    for tweet in newTweets
        targetState = tweet.state.toLowerCase()
        
        if tweet.keyword

            stateData[tweet.state][tweet.keyword]++
            if stateData[tweet.state][tweet.keyword] > maxTweets
                #reset whole display
                setStateDisplay()
            else
                ident = targetState.replace(/\s/g,"_")
                $(".#{ident}.#{tweet.keyword}").css "width",(stateData[tweet.state][tweet.keyword] / maxTweets * 100) + "%"

        i = stateData[tweet.state].seahawks / (stateData[tweet.state].broncos + stateData[tweet.state].seahawks)

        map.states[targetState].raiseUp(stateData[tweet.state].seahawks || 0, stateData[tweet.state].broncos || 0, tweet.keyword)


$("#tweetBroncos").on "click", () -> map.sendTweet "Broncos"
$("#tweetSeahawks").on "click", () -> map.sendTweet "Seahawks"
