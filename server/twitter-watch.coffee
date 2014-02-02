Twitter = require "node-twitter-api"
pg = require "pg"
request = require "request"
Config = require "./config.json"


twitter = new Twitter
    consumerKey: 'lT8Jq0lBrYB8Rhv6N0CNtA',
    consumerSecret: '0fo3XFCYf1dpMX2QSnnawiHhDc4N6bGARqsf5UF0xbI',
    callback: 'http://yoururl.tld/something'

accessToken = "18059424-ECTDnGtruPrtZAO9gaqODSc6iwS7sjomCsgtXw7wS"
tokenSecret = "nRBNtKjL8ybZGH2ojxPvYMD0kur3Fp0ldO3vfvuTic074"

twitter.getStream "filter", {track:"broncos,seahawks"},accessToken,tokenSecret, (err,tweet) ->
    if err then return console.log err;
    console.log tweet.created_at
    # No location at all
    if tweet.user.location == "" then return
    urlToGet = Config.geocodeUrl
    urlToGet += "?q=" + tweet.user.location
    urlToGet += "&placetype=adm&placetype=city&placetype=citysubdivision&placetype=politicalentity"
    urlToGet += "&format=JSON&spellchecking=true"

    request {
        url: urlToGet
        json:true
        
    }, (err,response,body) ->
        if !body.response?.docs || body.response.docs.length == 0
            console.log "no results"
            return
        
        firstResult = body.response.docs[0]
        lowerCaseTweet = tweet.text.toLowerCase()

        broncoTerms = ["broncos", "bronco", "colorado", "peyton", "manning"]
        seahawkTerms = ["seahawks", "sea hawks", "seattle", "wilson","russell"]

        check = (terms, twAccount) ->
            for term in terms
                if lowerCaseTweet.indexOf(term) > -1 then return true
            if tweet.retweeted_status?.user.screen_name == twAccount
                return true
            return false


        isBroncos = check(broncoTerms,"broncos")

        isSeahawks = check(seahawkTerms,"seahawks")

        keyword = null
        if isBroncos && !isSeahawks then keyword = "broncos"
        else if isSeahawks && !isBroncos then keyword = "seahawks"

        if keyword == null
          console.log isBroncos, isSeahawks,lowerCaseTweet



        pg.connect Config.dbConString, (err, client, done) ->
            if err then console.log err
            client.query """
                INSERT INTO tweets (tweetid,latlng,locstring,userid,keyword,saved_at,state_name)
                values (
                    $1,ST_GeomFromText('POINT(' || $3 || ' ' || $2 ||')',4326),$4,$5,$6,$7,
                    (select state from statesp020 as states where
                        ST_GeomFromText('POINT(' || $3 || ' ' || $2 ||')',4326) && states.geom
                        AND ST_INTERSECTS(states.geom,ST_GeomFromText('POINT(' || $3 || ' ' || $2 ||')',4326))
                        )
                )
                """,
            [tweet.id_str,String(firstResult.lat), String(firstResult.lng),tweet.user.location,tweet.user.screen_name,keyword,new Date()],
            (err,result) ->
                if err then console.log err
                console.log tweet.user.location + " for " + keyword
                done()