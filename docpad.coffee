fs = require 'fs'
YAML = require 'yamljs'
moment = require 'moment'
richtypo = require 'richtypo'

docpadConfig = {

    databaseCache: false,

    templateData:
        cutTag: '<!-- cut -->'
        site: {}
        pageTitle: -> 
            if @document.title
                "#{@document.title} — #{@site.title}"
            else
                @site.title
        pageDescription: ->
            if @document.description
                "#{@document.description}"
            else
                @site.description
        pageKeywords: ->
            if @document.keywords
                "#{@document.keywords}"
            else
                @site.keywords

    collections:
        posts: (database) ->
            database.findAllLive(
                {relativeOutDirPath: 'blog'}, 
                [date:-1]
            )
        clients: (database) ->
            database.findAllLive(
                {relativeOutDirPath: '4clients', pageOrder: $exists true},
                [pageOrder:1]
            )
        pages: (database) ->
            database.findAllLive(
                {pageOrder: $exists: true}, 
                [pageOrder:1]
            )

    environments:
        en:
            documentsPaths: ['data/en']
            outPath: 'out/en'
        ru:
            documentsPaths: ['data/ru']
            outPath: 'out/ru'

    plugins:
        highlightjs:
            aliases:
                yaml: 'python'
        jade:
            jadeOptions:
                pretty: true
        partials:
            partialsPath: process.cwd() + '/src/layouts/partials'

    events:
        generateBefore: (opts) ->
            lang = @docpad.config.env
            @docpad.getConfig().templateData.site = (YAML.load "src/lang/#{lang}.yml")
            moment.lang(lang)
            richtypo.lang(lang)
        serverExtended: (opts) ->
            {server} = opts
            docpad = @docpad
            latestConfig = docpad.getConfig()
            oldUrls = latestConfig.templateData.site.oldUrls or []
            newUrl = latestConfig.templateData.site.url

            server.use (req,res,next) ->
                if req.headers.host in oldUrls
                    res.redirect(newUrl+req.url, 301)
                else
                    next()
}

module.exports = docpadConfig
