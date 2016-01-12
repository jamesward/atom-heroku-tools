{View} = require 'space-pen'
{SelectListView} = require 'atom-space-pen-views'

Heroku = require 'heroku-client'
HerokuSourceDeployer = require 'heroku-source-deployer'
netrc = require 'netrc2'

module.exports =
  class HerokuDeployView extends SelectListView

    apps: []

    initialize: ->
      super
      @addClass('overlay from-top')
      @modalPanel ?= atom.workspace.addModalPanel(item: this)
      @modalPanel.hide()
      @loadApps

    loadApps: ->
      @setLoading('Loading your Heroku apps...')

      machines = netrc()
      herokuAuth = machines['api.heroku.com']

      if herokuAuth.length == 2
        herokuToken = herokuAuth[1]

        heroku = new Heroku
          token: herokuToken

        heroku.apps().list()
        .then (apps) =>
          @setLoading('')
          @apps = apps
          @setItems(apps)

    viewForItem: (item) ->
      "<li>#{item.name}</li>"

    getFilterKey: ->
      'name'

    confirmed: (item) ->

      machines = netrc()
      herokuAuth = machines['api.heroku.com']

      if (atom.project.rootDirectories.length > 0 && herokuAuth.length == 2)
        herokuToken = herokuAuth[1]
        projectDir = atom.project.rootDirectories[0].path

        atom.notifications.addInfo('Uploading to Heroku...')

        HerokuSourceDeployer.deployDir(herokuToken, item.name, projectDir)
          .then (deployInfo) ->
            url = 'https://dashboard.heroku.com/apps/' + item.name + '/activity/builds/' + deployInfo.id
            if (deployInfo.status == 'pending')
              atom.notifications.addInfo('The application is building.  Check the build log: ' + url)
              HerokuSourceDeployer.buildComplete(herokuToken, item.name, deployInfo.id)
                .then (buildResult) ->
                  if (buildResult.build.status == 'succeeded')
                    atom.notifications.addSuccess('The build completed successfully.  Check the build log: ' + url)
                  else
                    atom.notifications.addError('The build failed.  Check the build log: ' + url)
                .catch (err) ->
                  atom.notifications.addError('The build failed: ' + err)
            else if (deployInfo.status == 'error')
              atom.notifications.addError('Error building the application.  Check the build log: ' + url)

          .catch (err) ->
            atom.notifications.addError('Error building the application: ' + err)

        @hide()

    cancelled: ->
      @modalPanel.hide()

    getEmptyMessage: ->
      'No apps.  Create one!'

    show: ->
      @setItems(@apps)
      @modalPanel.show()
      @focusFilterEditor()
      @loadApps()

    hide: ->
      @modalPanel.hide()
