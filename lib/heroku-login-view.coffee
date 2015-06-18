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
        @subview 'secondFactorEditor', new PasswordView("Two-factor code (if enabled)")
        @div class: 'text-error block', outlet: 'errorLabel'
        @div class: 'block', =>
          @button click: 'login', id: 'loginButton', class: 'btn btn-primary', outlet: 'loginButton', 'Log in'
          @button click: 'cancel', id: 'cancelButton', class: 'btn', 'Cancel'

    initialize: ->
      @modalPanel = atom.workspace.addModalPanel(item: this, visible: false)
      @usernameModel = @usernameEditor.getModel()
      @passwordModel = @passwordEditor.getModel()
      @secondFactorModel = @secondFactorEditor.getModel()

      @passwordEditor.on 'keydown', (event) =>
        if (event.keyCode == 13)
          @login()

      @secondFactorEditor.on 'keydown', (event) =>
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
      @secondFactorModel.setText ''
      @modalPanel.hide()

    cancel: ->
      @hide()

    disable: ->
      @usernameEditor.setEnabled false
      @passwordEditor.setEnabled false
      @secondFactorEditor.setEnabled false
      @loginButton.attr 'disabled', 'disabled'

    enable: ->
      @usernameEditor.setEnabled true
      @passwordEditor.setEnabled true
      @secondFactorEditor.setEnabled true
      @loginButton.removeAttr 'disabled'

    login: ->
      @disable()
      @errorLabel.hide()

      @username = @usernameModel.getText()
      @password = @passwordModel.getText()
      @secondFactor = @secondFactorModel.getText()

      request = require('request')

      options =
        json: true
        auth:
          user: @username
          pass: @password
        headers:
          'Heroku-Two-Factor-Code': @secondFactor

      request.post 'https://api.heroku.com/oauth/authorizations', options, (error, response, body) =>
        if !error and response.statusCode == 201
          accessToken = body.access_tokens[0].token

          netrc = require('netrc2')
          machines = netrc()
          machines['api.heroku.com'] = [@username, accessToken]
          machines.save()
          
          @hide()
        else
          @errorLabel.text('Login error: ' + body.error)
          @errorLabel.show()
          @enable()
