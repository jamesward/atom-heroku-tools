{View} = require 'space-pen'
{SelectListView} = require 'atom-space-pen-views'

{apps, deploy} = require './util'

module.exports = class HerokuDeployView extends SelectListView

    apps: []

    initialize: ->
      super
      @addClass('overlay from-top')
      @loadApps

    loadApps: ->
      @setLoading('Loading your Heroku apps...')

      apps().then (apps) =>
          @setLoading('')
          @apps = apps
          @setItems(apps)

    viewForItem: (item) ->
      "<li>#{item.name}</li>"

    getFilterKey: ->
      'name'

    confirmed: (item) ->
      if atom.project.rootDirectories.length > 0
        deploy(item.name, atom.project.rootDirectories[0].path).then () =>
          @cancelled()
        .catch (error) ->
          console.log(error)

    cancelled: ->
      # use the parentElement otherwise we recurse
      atom.commands.dispatch(this.element.parentElement, 'core:cancel')

    getEmptyMessage: ->
      'No apps.  Create one!'

    attached: ->
      @setItems(@apps)
      @focusFilterEditor()
      @loadApps()
