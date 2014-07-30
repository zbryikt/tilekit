TileLayer = (config) ->
  @visible = true
  @ <<< config
  @url = @url.replace /\/$/, ""
  @tileSize = new google.maps.Size 256,256
  @vector = null
  $.ajax (if @bv => @bv else "#{@url}/vector.json")
  .success (d) ~> @vector = d
  @map.overlayMapTypes.setAt 0, null
  @map.overlayMapTypes.insertAt 0, @
  @layer = config.map.overlayMapTypes.0
  @

TileLayer.prototype <<< do
  toggle: (visible) ->
    @visible = if typeof(visible) == "undefined" => !@visible else visible
    @map.overlayMapTypes.setAt 0, if @visible => @ else null
  getTile: (c, z, doc) ->
    div = doc.createElement \div
    if @vector and !check(@vector,z,c.x,c.y) => return div
    div
      ..style
        ..width = "#{@tileSize.width}px"
        ..height = "#{@tileSize.height}px"
        ..opacity = "#{@opacity}"
        ..background = "url(#{@url}/#z/#{c.x}/#{c.y}.png) center center no-repeat"

module ?= {}
module.exports = TileLayer
