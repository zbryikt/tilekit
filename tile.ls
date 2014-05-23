TILE_SIZE = 256

d2r = -> it * Math.PI / 180
r2d = -> 180 * it / Math.PI 
bound = (value, opt_min, opt_max) ->
  if opt_min != null => value = Math.max(value, opt_min)
  if opt_max != null => value = Math.min(value, opt_max)
  value

Point = (x, y) -> {x, y}
LatLng = (lat, lng) -> 
  {_lat: lat,_lng: lng} <<< do
    lat: -> @_lat
    lng: -> @_lng

MercatorProjection = do
  Point: Point
  LatLng: LatLng
  TILE_SIZE: TILE_SIZE
  pixelOrigin_: new Point(TILE_SIZE / 2, TILE_SIZE / 2)
  pixelsPerLonDegree_: TILE_SIZE / 360
  pixelsPerLonRadian_: TILE_SIZE / (2 * Math.PI)
  ll2p: (latlng, p) -> 
    point = p or new Point 0,0
    origin = @pixelOrigin_
    siny = bound Math.sin(d2r latlng.lat!), -0.9999, 0.9999
    console.log origin.x, latlng.lng!
    point.x = origin.x + latlng.lng! * @pixelsPerLonDegree_
    point.y = origin.y + 0.5 * Math.log((1 + siny) / (1 - siny)) * -@pixelsPerLonRadian_
    point
  p2ll: (p) ->
    o = @pixelOrigin_
    latRadians = ( p.y - o.y ) / -@pixelsPerLonRadian_
    lng = ( p.x - o.x ) / @pixelsPerLonDegree_
    lat = r2d(2 * Math.atan(Math.exp latRadians) - Math.PI / 2)
    new LatLng(lat, lng)
  t2ll: (x,y,z) ->
    numTiles = 1 .<<. z
    @p2ll(new Point x * TILE_SIZE / numTiles, y * TILE_SIZE / numTiles)

module.exports = MercatorProjection
(if @window? => @tile = {} else @) <<< MercatorProjection
