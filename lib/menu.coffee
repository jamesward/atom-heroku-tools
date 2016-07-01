Heroku = require('heroku-client')
netrc = require('netrc2')

module.exports = Menu =

  update: ->
    machines = netrc()
    herokuAuth = machines['api.heroku.com']

    if herokuAuth != undefined && herokuAuth.length == 2
      herokuLogin = herokuAuth[0]
      herokuToken = herokuAuth[1]

      heroku = new Heroku
        token: herokuToken

      heroku.account().info()
        .then (info) =>
          @loggedIn()
        .catch (err) =>
          @loggedOut()

    else
      @loggedOut()

  herokuMenu: -> (t for t in atom.menu.template when t.label is 'Heroku')[0]

  loggedIn: ->
    @herokuMenu().submenu = [
      {
        label: 'Deploy'
        command: 'heroku:deploy'
      }
      {
        label: 'Logout'
        command: 'heroku:logout'
      }
    ]
    atom.menu.update()

  loggedOut: ->
    @herokuMenu().submenu = [
      {
        label: 'Login'
        command: 'heroku:login'
      }
    ]
    atom.menu.update()
