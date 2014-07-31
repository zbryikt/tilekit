TileLayer = (config) ->
  @ <<< config
  @idx = TileLayer.idx or 0
  TileLayer.idx = (TileLayer.idx or 0) + 1
  if typeof(@visible)=="undefined" => @visible = true
  if typeof(@enabled)=="undefined" => @enabled = true
  if @url => @url = @url.replace /\/$/, ""
  @tileSize = new google.maps.Size 256,256
  @vector = null
  if @getimg =>
    $.ajax url: (if @bv => @bv else "#{@url}/vector.json"), dataType: \json
    .success (d) ~> @vector = d
  @map.overlayMapTypes.setAt @idx, null
  if @visible => @map.overlayMapTypes.insertAt @idx, @
  gms.e.addListener @map, \zoom_changed, (z) ~> @onZoomChanged @map.getZoom!
  @

TileLayer.prototype <<< do
  onZoomChanged: (z) ->
    if typeof(@showLv)=="undefined" => return
    if z < @showLv => @disable!
    else if !@enabled => @enable!

  enable: ->
    @enabled = true
    @toggle @visible

  disable: ->
    @enabled = false
    @toggle @visible

  toggle: (visible) ->
    @visible = if typeof(visible) == "undefined" => !@visible else visible
    @map.overlayMapTypes.setAt @idx, if @visible and @enabled => @ else null

  getTile: (c, z, doc) ->
    {x,y} = c
    div = doc.createElement \div
    div.style
      ..width = "#{@tileSize.width}px"
      ..height = "#{@tileSize.height}px"
      ..opacity = "#{@opacity}"
      ..backgroundPosition = "center center"
      ..backgroundAttachment = "no-repeat"
    if @vector and !check(@vector,z,x,y) =>
      if !(@extend and check(@vector,z - 1, parseInt(x/2), parseInt(y/2))) => return div
      [dx,dy] = [ ( (x % 2) ) * 256, ( (y % 2) ) * 256]
      [z,x,y] = [z - 1, parseInt(x / 2), parseInt(y / 2)]
      div.style.backgroundPosition = "-#{dx}px -#{dy}px"
      div.style.backgroundSize = "512px 512px"
    div.style.backgroundImage = if @getimg => "url(#{@getimg(z,x,y)})" else "url(#{@url}/#z/#{x}/#{y}.png)"
    div

module ?= {}
module.exports = TileLayer
