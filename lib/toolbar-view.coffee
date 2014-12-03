{$, $$, TextEditorView, View, Emitter} = require 'atom'

module.exports =
  class JekyllManagerView extends View
    @content: ->
      @div tabindex: -1, class: 'jekyll-manager-panel', =>

        @div class: 'block', =>
          @span id: 'jekyllVersion', outlet: 'jekyllVersion', 'Jekyll 0.0.0'
          @span id: 'jekyllPWD', outlet: 'jekyllPWD', ' in ' + atom.project.getPath()
          @div class: 'buttons', =>
            @div class: 'btn-group', =>
              @button class: 'btn', id: 'toggleButton', outlet: 'toggleButton', click: 'toggleServer', 'Loading...'
              @button class: 'btn', click: 'openFull', 'Full View'
              @button class: 'btn', click: 'hidePanel', 'Close'

        @div class: 'block', =>
          @div class: 'jtconsole', outlet: 'jtconsole', id: 'jtconsole'

    initialize: (emitter) ->
      @emitter = emitter

      @getVersion()
      @bindEvents()

    setPanel: (panel) ->
      @panel = panel
      @initToggleButton() # We do this here because now the button exists on screen
      @initConsole()

    hidePanel: ->
      @panel.hide()

    openFull: ->
      @panel.hide()
      atom.workspaceView.open('atom://jekyll')

    refresh: ->
      @initToggleButton()

    initConsole: ->
      @emitter.on 'jekyll:console-message', (message) ->
        $('#jtconsole').append(message)
        $('#jtconsole').animate({"scrollTop": $('#jtconsole')[0].scrollHeight}, "fast")

    initToggleButton: ->
      @emitter.on 'jekyll:server-status-reply', (status) ->
        if status == 'Off'
          $('#toggleButton').html('Start Server')
        else
          $('#toggleButton').html('Stop Server')

      @emitter.emit 'jekyll:server-status'

    bindEvents: ->
      @on 'core:cancel core:close', => @panel?.hide()

    getVersion: ->
      @emitter.emit 'jekyll:version'
      @emitter.on 'jekyll:version-reply', (data) ->
        $('#jekyllVersion').html(data)

    toggleServer: (event, element) ->
      if element.html() == 'Start Server'
        @emitter.emit 'jekyll:start-server'
      else
        @emitter.emit 'jekyll:stop-server'