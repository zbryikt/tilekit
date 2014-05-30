type = 0
CoordMapType = -> @ <<< {tileSize: it}
CoordMapType.prototype.getTile = (c, zoom, doc) ->
  div = doc.createElement \div
  #if !check(floodmap, zoom, c.x, c.y) => return div
  ll1 = tile.t2ll c.x, c.y, zoom
  ll2 = tile.t2ll c.x + 1, c.y, zoom
  ll3 = tile.t2ll c.x, c.y + 1, zoom
  ll4 = tile.t2ll c.x + 1, c.y + 1, zoom
  twd1 = coord.toTwd97 {lat: ll1.lat!, lng: ll1.lng!}
  twd2 = coord.toTwd97 {lat: ll2.lat!, lng: ll2.lng!}
  twd3 = coord.toTwd97 {lat: ll3.lat!, lng: ll3.lng!}
  twd4 = coord.toTwd97 {lat: ll4.lat!, lng: ll4.lng!}
  twd = [twd1, twd2, twd3, twd4]
  minx = Math.min.apply(null, twd.map -> it.0)
  maxx = Math.max.apply(null, twd.map -> it.0)
  miny = Math.min.apply(null, twd.map -> it.1)
  maxy = Math.max.apply(null, twd.map -> it.1)
  minx = twd1.0    # 3 1
  maxx = twd4.0    # 2 4
  miny = twd4.1    # 3 4
  maxy = twd1.1    # 2 1
  div
    ..innerHTML = "#zoom #c"
    ..style
      ..width = "#{@tileSize.width}px";
      ..height = "#{@tileSize.height}px";
      ..opacity = "0.6"
  console.log type, div
  if type==1 => div.style.background = "url(http://zbryikt.github.io/flood-map/img/#zoom/#{c.x}/#{c.y}.png) center center no-repeat"
  if type==2 => div.style.background = "url(https://raw.githubusercontent.com/zbryikt/tile-cityusage/gh-pages/#zoom/#{c.x}/#{c.y}.png) center center no-repeat"
  if type==3 => div.style.background = "url(http://ngis.tcd.gov.tw:8080/geoserver/wms?Request=GetMap&SERVICE=WMS&VERSION=1.1.1&BGCOLOR=0xFFFFFF&TRANSPARENT=TRUE&SRS=EPSG:3826&FORMAT=image/png&LAYERS=LandUse&width=256&height=256&BBOX=#minx,#miny,#maxx,#maxy)"
  div

main = ($scope,$timeout) ->
  #$scope.taipei = new google.maps.LatLng 25.062706, 121.533563
  $scope.taipei = new google.maps.LatLng 25.039155, 121.549678 #25.062706, 121.533563
  $scope.map-option = zoom: 18, minZoom: 12, maxZoom: 18, center: $scope.taipei
  $scope.type = 0
  $scope.settype = -> 
    $scope.type = it
    type := it
  $scope.init = ->
    $scope.map = new google.maps.Map(document.getElementById(\map), $scope.map-option)
    a = new CoordMapType(new google.maps.Size 256,256)
    $scope.map.overlayMapTypes.insertAt 0, a

  google.maps.event.addDomListener window, \load, -> $scope.$apply -> $scope.init!
