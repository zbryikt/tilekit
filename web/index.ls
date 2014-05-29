CoordMapType = -> @ <<< {tileSize: it}
CoordMapType.prototype.getTile = (coord, zoom, doc) ->
  div = doc.createElement \div
  #if !check(floodmap, zoom, coord.x, coord.y) => return div
  div
    ..style
      ..width = "#{@tileSize.width}px";
      ..height = "#{@tileSize.height}px";
      ..opacity = "0.6"
      #..background = "url(http://zbryikt.github.io/flood-map/img/#zoom/#{coord.x}/#{coord.y}.png) center center no-repeat"
      ..background = "url(http://zbryikt.github.io/tile-cityusage/#zoom/#{coord.x}/#{coord.y}.png) center center no-repeat"

main = ($scope,$timeout) ->
  $scope.taipei = new google.maps.LatLng 25.062706, 121.533563
  $scope.map-option = zoom: 15, minZoom: 15, maxZoom: 17, center: $scope.taipei
  $scope.isAddrToggled = false
  $scope.toggleAddr = -> $scope.isAddrToggled = !$scope.isAddrToggled
  $scope.init = ->
    $scope.map = new google.maps.Map(document.getElementById(\map), $scope.map-option)
    a = new CoordMapType(new google.maps.Size 256,256)
    $scope.map.overlayMapTypes.insertAt 0, a

  google.maps.event.addDomListener window, \load, -> $scope.$apply -> $scope.init!
