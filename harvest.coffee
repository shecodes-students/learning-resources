path = require 'path'
fs = require 'fs'

Twit = require 'twit'

fs = require 'fs'

twitter_options = {
    count: 200
}
data = fs.readFileSync path.join(__dirname, 'README.md'), 'utf8'
data.replace /last imported tweet\:\s*(.*)/g, (match, id)  ->
    twitter_options.since_id =  id

console.error 'last tweet id was:', twitter_options.since_id

config = JSON.parse fs.readFileSync path.join process.env.HOME, '.twit-cli'
twit = new Twit config

twit.get 'statuses/mentions_timeline', twitter_options, (err, data, response) ->
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
            i = 0
            for author in mentions
                if i++ is 0 then continue # first mention always is @shecodes_ 
                console.log "- aauthor: @#{author}"
            console.log "- contributed_by: @#{user.screen_name}"
            console.log '- tweet_id: ' + id
            console.log ''
    console.log 'last imported tweet: ' + data[0].id
