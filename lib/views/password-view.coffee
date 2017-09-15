{View} = require 'space-pen'

MiniTextView = require './mini-text-view'

module.exports = class PasswordView extends MiniTextView
  initialize: (placeholderText) ->
    super(placeholderText)
    @getModel().getBuffer().onDidChange =>
      if @getModel().getText() is ''
        @getEditor().css('-webkit-text-security': 'none')
      else
        @getEditor().css('-webkit-text-security': 'disc')
