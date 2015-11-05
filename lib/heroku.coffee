Heroku = require 'heroku-client'

Menu = require './menu'

HerokuLoginView = require './heroku-login-view'
{CompositeDisposable} = require 'atom'

module.exports = HerokuTools =

    activate: ->
      Menu.update()

      @subscriptions = new CompositeDisposable
      @subscriptions.add atom.commands.add 'atom-workspace',
        'heroku:login': => @login()
        'heroku:logout': => @logout()
        'heroku:deploy': => @deploy()
        'core:cancel': => @HerokuLoginView.hide()
        'core:close': => @HerokuLoginView.hide()

      @HerokuLoginView = new HerokuLoginView

    deactivate: ->
      @subscriptions.dispose()
      @HerokuLoginView.destroy()

    serialize: ->

    login: ->
      @HerokuLoginView.show()

    logout: ->
      netrc = require 'netrc2'
      machines = netrc()
      machines['api.heroku.com'] = [null]
      machines.save()
      Menu.update()

    deploy: ->
