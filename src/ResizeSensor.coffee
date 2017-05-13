
emptyFunction = require "emptyFunction"
Type = require "Type"

type = Type "ResizeSensor"

type.defineMethods

  detach: ->
    if @_node
      @_callback = emptyFunction
      @_node.removeChild @_sensor
      @_node = null
      return

#
# Internal
#

type.defineValues (node, callback) ->

  _node: node

  _callback: callback

  _sensor: null

  _lastWidth: null

  _lastHeight: null

  _updating: no

type.initInstance -> @_attach()

type.defineBoundMethods

  _onScroll: ->

    unless @_updating
      @_updating = yes
      requestAnimationFrame @_onResize

    @_reset()
    return

  _onResize: ->
    @_updating = no

    if node = @_node
      width = node.offsetWidth
      height = node.offsetHeight

      if width isnt @_lastWidth
        @_lastWidth = width
        changed = yes

      if height isnt @_lastHeight
        @_lastHeight = height
        changed = yes

      if changed
        @_callback width, height, node
        return

type.defineMethods

  _attach: ->

    sensor = document.createElement "div"
    sensor.className = "resize-sensor"
    sensor.style.cssText = sensorStyle
    sensor.innerHTML = innerHTML

    @_sensor = sensor
    @_node.appendChild sensor

    if "static" is getComputedStyle @_node, "position"
      @_node.style.position = "relative"

    @_lastWidth = @_node.offsetWidth
    @_lastHeight = @_node.offsetHeight

    @_reset()

    sensor.childNodes[0].addEventListener "scroll", @_onScroll
    sensor.childNodes[1].addEventListener "scroll", @_onScroll
    return

  _reset: ->
    expand = @_sensor.childNodes[0]
    shrink = @_sensor.childNodes[1]

    expand.firstChild.style.width = "100000px"
    expand.firstChild.style.height = "100000px"

    expand.scrollLeft = 100000
    expand.scrollTop = 100000

    shrink.scrollLeft = 100000
    shrink.scrollTop = 100000
    return

module.exports = type.build()

sensorStyle = "position: absolute; left: 0; top: 0; right: 0; bottom: 0; overflow: hidden; z-index: -1; visibility: hidden;"
childStyle = "position: absolute; left: 0; top: 0; transition: 0s;"
innerHTML = """
<div class="resize-sensor-expand" style="#{sensorStyle}"><div style="#{childStyle}"></div></div>
<div class="resize-sensor-shrink" style="#{sensorStyle}"><div style="#{childStyle} width: 200%; height: 200%;"></div></div>
"""
