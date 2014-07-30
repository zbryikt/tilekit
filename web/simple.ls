main = ($scope,$timeout) ->
  $scope.taipei = new google.maps.LatLng 25.039155, 121.549678
  $scope.map-option = zoom: 18, minZoom: 8, maxZoom: 18, center: $scope.taipei
  $scope.init = ->
    $scope.map = new google.maps.Map(document.getElementById(\map), $scope.map-option)
    $scope.layer = new TileLayer do
      map: $scope.map
      url: \https://raw.githubusercontent.com/zbryikt/tile-cityusage/gh-pages/
      bv: \vector.json
      opacity: 0.5

  google.maps.event.addDomListener window, \load, -> $scope.$apply -> $scope.init!
