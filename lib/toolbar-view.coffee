{Emitter} = require 'atom'
{$, View} = require 'space-pen'

module.exports =
  class JekyllManagerView extends View
    @content: ->
      @div tabindex: -1, class: 'jekyll-manager-panel', =>

        @div class: 'block', =>
          @p =>
            @span id: 'jekyllVersion', outlet: 'jekyllVersion', 'Jekyll 0.0.0'
            @span id: 'jekyllPWD', outlet: 'jekyllPWD', ' in ' + atom.project.getPaths()[0]
          @div class: 'buttons', =>
            @div class: 'btn-group', =>
              @button class: 'btn', id: 'toggleButton', outlet: 'toggleButton', click: 'toggleServer', 'Loading...'
              @button class: 'btn', click: 'openFull', 'Full View'
              @button class: 'btn', click: 'hidePanel', 'Close'

    initialize: (emitter) ->
      @emitter = emitter

      @getVersion()

    setPanel: (panel) ->
      @panel = panel
      @initToggleButton() # We do this here because now the button exists on screen

    hidePanel: ->
      @panel.hide()

    openFull: ->
      @panel.hide()
      atom.workspaceView.open('atom://jekyll')

    refresh: ->
      @initToggleButton()

    initToggleButton: ->
      @emitter.on 'jekyll:server-status-reply', (status) ->
        if status == 'Off'
          $('#toggleButton').html('Start Server')
        else
          $('#toggleButton').html('Stop Server')

      @emitter.emit 'jekyll:server-status'

    getVersion: ->
      @emitter.emit 'jekyll:version'
      @emitter.on 'jekyll:version-reply', (data) ->
        $('#jekyllVersion').html(data)

    toggleServer: (event, element) ->
      if element.html() == 'Start Server'
        @emitter.emit 'jekyll:start-server'
      else
        @emitter.emit 'jekyll:stop-server'
