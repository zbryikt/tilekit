TileLayer = (config) ->
  @ <<< config
  if typeof(@visible)=="undefined" => @visible = true
  @url = @url.replace /\/$/, ""
  @tileSize = new google.maps.Size 256,256
  @vector = null
  $.ajax (if @bv => @bv else "#{@url}/vector.json")
  .success (d) ~> @vector = d
  @map.overlayMapTypes.setAt 0, null
  @map.overlayMapTypes.insertAt 0, @
  if @visible => @map.overlayMapTypes.insertAt 0, @
  @

TileLayer.prototype <<< do
  toggle: (visible) ->
    @visible = if typeof(visible) == "undefined" => !@visible else visible
    @map.overlayMapTypes.setAt 0, if @visible => @ else null
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
    
    div.style.backgroundImage = "url(#{@url}/#z/#{x}/#{y}.png)"
    div

module ?= {}
module.exports = TileLayer
