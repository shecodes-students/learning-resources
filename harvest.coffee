path = require 'path'
fs = require 'fs'

Twit = require 'twit'

config = JSON.parse fs.readFileSync path.join process.env.HOME, '.twit-cli'
twit = new Twit config

twit.get 'statuses/mentions_timeline', { count: 200 }, (err, data, response) ->
    for {id, user, text, entities} in data
        if text.match(/^contribute\s+@shecodes/i) is null then continue
        #console.log id, user.screen_name, text, entities.urls
        urls = (x.expanded_url for x in entities.urls)
        mentions = (x.screen_name for x  in entities.user_mentions)
        tags = (x.text for x  in entities.hashtags)
        
        # remove tags from text
        for t in tags
            text = text.replace '#' + t, ''

        # remove metnions
        for m in mentions
            text = text.replace '@' + m, ''

        # remove URLs
        for {url} in entities.urls
            text = text.replace url, ''

        text = text.replace /^contribute/, ''

        if urls?.length
            console.log "#[#{text.trim()}](#{urls[0]})"
            if tags?
                console.log "- tags: #{tags.join ' '}"
            for author in mentions
                console.log "- aauthor: @#{author}"
            console.log "- contributed_by: @#{user.screen_name}"
            console.log '- tweet_id: ' + id
            console.log ''
    console.log 'last imported tweet: ' + data[0].id
