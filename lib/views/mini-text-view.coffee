{View, TextEditorView} = require 'atom-space-pen-views'

# based on: https://github.com/spark/spark-dev-views/blob/master/src/mini-editor-view.coffee
module.exports = class MiniTextView extends View
  @content: ->
    @div class: 'mini-text-view', =>
      @subview 'editor', new TextEditorView(mini: true)
      @div class: 'editor-disabled', outlet: 'editorOverlay'

  initialize: (placeholderText) ->
    @editor.model.setPlaceholderText placeholderText
    @enabled = true
    @editor.on 'focus', =>
      if not @enabled
        @editor.blur()

  getModel: ->
    @editor.getModel()

  getEditor: ->
    @editor

  focus: ->
    @editor.element.focus()

  setEnabled: (isEnabled) ->
    @enabled = isEnabled
    if isEnabled
      @editorOverlay.hide()
    else
      @editorOverlay.show()
      @editor.blur()
