HerokuLoginView = require './heroku-login-view'
{CompositeDisposable} = require 'atom'

module.exports = HerokuTools =

    activate: ->
      @subscriptions = new CompositeDisposable
      @subscriptions.add atom.commands.add 'atom-workspace',
        'heroku:login': => @login()
        'core:cancel': => @HerokuLoginView.hide()
        'core:close': => @HerokuLoginView.hide()

      @HerokuLoginView = new HerokuLoginView

    deactivate: ->
      @subscriptions.dispose()
      @HerokuLoginView.destroy()

    serialize: ->

    login: ->
      @HerokuLoginView.show()
