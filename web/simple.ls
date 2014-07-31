main = ($scope,$timeout) ->
  $scope.taipei = new google.maps.LatLng 25.039155, 121.549678
  $scope.map-option = zoom: 18, minZoom: 8, maxZoom: 18, center: $scope.taipei
  $scope.init = ->
    $scope.map = new google.maps.Map(document.getElementById(\map), $scope.map-option)

    $scope.layer = new TileLayer do
      name: \landusage
      map: $scope.map
      url: \https://raw.githubusercontent.com/zbryikt/tile-cityusage/gh-pages/
      getimg: (z,x,y) ->
        return "http://maps.nlsc.gov.tw/S_Maps/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&STYLE=_null&TILEMATRIXSET=EPSG:3857&TILEMATRIX=EPSG:3857:#z&FORMAT=image/png&LAYER=nURBAN&TILEROW=#y&TILECOL=#x"
      bv: \vector.json
      opacity: 0.5
      extend: true

    $scope.layer2 = new TileLayer do
      name: \cityusage
      map: $scope.map
      url: \http://static.foundi.info/cityusage/
      bv: \vector.json
      opacity: 0.5
      extend: true

  google.maps.event.addDomListener window, \load, -> $scope.$apply -> $scope.init!
