Knox = require "knox"
Config = require "./config.json"
pg = require "pg"

s3 = Knox.createClient
    key: Config.s3Key
    secret: Config.s3Secret
    bucket: "www.thetweetometer.com"

doUpload = () ->
    tenSecsAgo = Date.now().valueOf() - (1000 * 10)
    pg.connect Config.dbConString, (err, client, done) ->
        client.query """
            select 

            tweets.tweetid, locstring, ST_Y(latlng) as lat, ST_X(latlng) as lng, tweets.saved_at,
            state_name as state, keyword
            from tweets
            where tweets.saved_at >= $1 and not state_name is null
            order by saved_at asc
        """,[new Date(tenSecsAgo)], (err,result) ->
            if err then throw err
            mapped = result.rows.map (row) ->
                row.saved_at = new Date(row.saved_at).valueOf() + Math.round(Math.random() * 1000)
                return row

            client.query """
            select count(*), keyword, state_name as state from tweets
            where tweets.saved_at < $1
            and state_name is not null
            group by state, tweets.keyword

            
            """,[new Date(tenSecsAgo)], (err,result) ->
                if err then throw err
                states = {}

                for row in result.rows
                    if !states[row.state]
                        states[row.state] = {}
                    states[row.state][row.keyword || "none"] = parseInt(row.count)

                done()
                
                dataTogether = 
                    lastTenSecs: mapped
                    stateTotals: states

                dataString = JSON.stringify(dataTogether)
                if Config.saveLocally
                    require("fs").writeFile "../web/data/data.json", dataString
                    setTimeout doUpload, 1000 * 10
                    return

                req = s3.put "/data/data.json", {
                    "Content-Length": new Buffer(dataString).length
                    "Content-Type": "application/json"
                    'x-amz-acl': 'public-read'
                }

                req.on "response", (res) ->
                    console.log "uploaded"
                    setTimeout doUpload, 1000 * 10

                req.end(dataString)
                   
    ###
    test = "test"

    req = s3.put "/data/test.txt", {
        "Content-Length": test.length
        "Content-Type": "text/plain"
        'x-amz-acl': 'public-read'
    }

    req.on "response", (res) ->
        console.log res

    req.end(test)
    ###


doUpload()