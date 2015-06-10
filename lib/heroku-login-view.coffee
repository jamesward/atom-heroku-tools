{View} = require 'space-pen'

MiniTextView = require './views/mini-text-view'
PasswordView = require './views/password-view'

# based on: https://github.com/spark/spark-dev/blob/master/lib/views/login-view.coffee
module.exports =
  class HerokuLoginView extends View

    @content: ->
      @div =>
        @h1 'Log in to Heroku'
        @subview 'usernameEditor', new MiniTextView("Username")
        @subview 'passwordEditor', new PasswordView("Password")
        @div class: 'text-error block', outlet: 'errorLabel'
        @div class: 'block', =>
          @button click: 'login', id: 'loginButton', class: 'btn btn-primary', outlet: 'loginButton', 'Log in'
          @button click: 'cancel', id: 'cancelButton', class: 'btn', 'Cancel'

    initialize: ->
      @modalPanel = atom.workspace.addModalPanel(item: this, visible: false)
      @usernameModel = @usernameEditor.getModel()
      @passwordModel = @passwordEditor.getModel()
      @passwordEditor.on 'keydown', (event) =>
        if (event.keyCode == 13)
          @login()

    destroy: ->
      @detach()

    show: ->
      @enable()
      @modalPanel.show()
      @errorLabel.hide()
      @usernameEditor.focus()

    hide: ->
      @usernameModel.setText ''
      @passwordModel.setText ''
      @modalPanel.hide()

    cancel: ->
      @hide()

    disable: ->
      @usernameEditor.setEnabled false
      @passwordEditor.setEnabled false
      @loginButton.attr 'disabled', 'disabled'

    enable: ->
      @usernameEditor.setEnabled true
      @passwordEditor.setEnabled true
      @loginButton.removeAttr 'disabled'

    login: ->
      @disable()
      @errorLabel.hide()

      @username = @usernameModel.getText()
      @password = @passwordModel.getText()

      request = require('request');

      options =
        json: true
        auth:
          user: @username
          pass: @password

      request.post 'https://api.heroku.com/oauth/authorizations', options, (error, response, body) =>
        if !error and response.statusCode == 201
          accessToken = body.access_tokens[0].token
          fs = require('fs')
          # todo: replace existing value if it exists
          fs.appendFile '.env', 'HEROKU_API_TOKEN=' + accessToken
          @hide()
        else
          @errorLabel.text('Login error: ' + body.error)
          @errorLabel.show()
          @enable()
