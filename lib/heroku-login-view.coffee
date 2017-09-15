{View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'

MiniTextView = require './views/mini-text-view'
PasswordView = require './views/password-view'

Menu = require './menu'
{login} = require './util'

module.exports = class HerokuLoginView extends View

    @content: ->
      @div =>
        @h1 'Log in to Heroku'
        @subview 'usernameEditor', new MiniTextView('Username')
        @subview 'passwordEditor', new PasswordView('Password')
        @subview 'secondFactorEditor', new PasswordView('Two-factor code (if enabled)')
        @div class: 'text-error block', outlet: 'errorLabel'
        @div class: 'block', =>
          @button click: 'doLogin', id: 'loginButton', class: 'btn btn-primary', outlet: 'loginButton', 'Log in'
          @button click: 'cancel', id: 'cancelButton', class: 'btn', 'Cancel'

    initialize: ->
      @usernameEditor.on 'keydown', (event) =>
        if (event.keyCode == 9)
          @passwordEditor.focus()
          event.preventDefault()

      @passwordEditor.on 'keydown', (event) =>
        if (event.keyCode == 13)
          @doLogin()
        if (event.keyCode == 9)
          @secondFactorEditor.focus()
          event.preventDefault()

      @secondFactorEditor.on 'keydown', (event) =>
        if (event.keyCode == 13)
          @doLogin()

      @loginButton.on 'keydown', (event) =>
        if (event.keyCode == 13)
          @doLogin()

    attached: ->
      @usernameEditor.focus()

    cancel: ->
      atom.commands.dispatch(this.element, 'core:cancel')

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

    doLogin: ->
      @disable()
      @errorLabel.hide()

      @username = @usernameEditor.getModel().getText()
      @password = @passwordEditor.getModel().getText()
      @secondFactor = @secondFactorEditor.getModel().getText()

      login(@username, @password, @secondFactor).then (accessToken) =>
        Menu.update()
        @cancel()
      .catch (error) =>
        @errorLabel.text('Login error: ' + error)
        @errorLabel.show()
        @enable()
