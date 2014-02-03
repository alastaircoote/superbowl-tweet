map.sendTweet = (team) ->
    locSuccess = (loc) ->
        #$("#locating").hide()
        #$("#mapholder").css "visibility", ""
        locGeoJson = {
            type: "Point"
            coordinates: [loc.coords.longitude, loc.coords.latitude]
        }
        for state in map.stateShapes
            #console.log state.geometry, locGeoJson
            if gju.pointInPolygon locGeoJson, state.geometry
                console.log state
                text = "I'm claiming #{state.properties.STATE_NAME} as #{team} territory on www.thetweetometer.com!"
                window.location = "https://twitter.com/intent/tweet?text=#{text}&via=_alastair"
                break
        console.log "wuuh"

    locFail = () ->
        $("#locating").hide()
        $("#mapholder").css "visibility", ""
        alert "Couldn't find your location!"
    $("#locating").show()
    $("#mapholder").css "visibility", "hidden"
    navigator.geolocation.getCurrentPosition locSuccess, locFail