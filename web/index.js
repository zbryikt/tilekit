// Generated by LiveScript 1.2.0
var type, CoordMapType, main;
type = 0;
CoordMapType = function(it){
  return this.tileSize = it, this;
};
CoordMapType.prototype.getTile = function(c, zoom, doc){
  var div, ll1, ll2, ll3, ll4, twd1, twd2, twd3, twd4, twd, minx, maxx, miny, maxy, x$, y$;
  div = doc.createElement('div');
  ll1 = tile.t2ll(c.x, c.y, zoom);
  ll2 = tile.t2ll(c.x + 1, c.y, zoom);
  ll3 = tile.t2ll(c.x, c.y + 1, zoom);
  ll4 = tile.t2ll(c.x + 1, c.y + 1, zoom);
  twd1 = coord.toTwd97({
    lat: ll1.lat(),
    lng: ll1.lng()
  });
  twd2 = coord.toTwd97({
    lat: ll2.lat(),
    lng: ll2.lng()
  });
  twd3 = coord.toTwd97({
    lat: ll3.lat(),
    lng: ll3.lng()
  });
  twd4 = coord.toTwd97({
    lat: ll4.lat(),
    lng: ll4.lng()
  });
  twd = [twd1, twd2, twd3, twd4];
  minx = Math.min.apply(null, twd.map(function(it){
    return it[0];
  }));
  maxx = Math.max.apply(null, twd.map(function(it){
    return it[0];
  }));
  miny = Math.min.apply(null, twd.map(function(it){
    return it[1];
  }));
  maxy = Math.max.apply(null, twd.map(function(it){
    return it[1];
  }));
  minx = twd1[0];
  maxx = twd4[0];
  miny = twd4[1];
  maxy = twd1[1];
  x$ = div;
  x$.innerHTML = zoom + " " + c;
  y$ = x$.style;
  y$.width = this.tileSize.width + "px";
  y$.height = this.tileSize.height + "px";
  y$.border = "1px solid #000";
  y$.opacity = "0.6";
  console.log(type, div);
  if (type === 1) {
    div.style.background = "url(http://zbryikt.github.io/flood-map/img/" + zoom + "/" + c.x + "/" + c.y + ".png) center center no-repeat";
  }
  if (type === 2) {
    div.style.background = "url(https://raw.githubusercontent.com/zbryikt/tile-cityusage/gh-pages/" + zoom + "/" + c.x + "/" + c.y + ".png) center center no-repeat";
  }
  if (type === 3) {
    div.style.background = "url(http://ngis.tcd.gov.tw:8080/geoserver/wms?Request=GetMap&SERVICE=WMS&VERSION=1.1.1&BGCOLOR=0xFFFFFF&TRANSPARENT=TRUE&SRS=EPSG:3826&FORMAT=image/png&LAYERS=LandUse&width=256&height=256&BBOX=" + minx + "," + miny + "," + maxx + "," + maxy + ")";
  }
  return div;
};
main = function($scope, $timeout){
  $scope.taipei = new google.maps.LatLng(25.039155, 121.549678);
  $scope.mapOption = {
    zoom: 18,
    minZoom: 8,
    maxZoom: 18,
    center: $scope.taipei
  };
  $scope.type = 0;
  $scope.settype = function(it){
    $scope.type = it;
    return type = it;
  };
  $scope.init = function(){
    var a;
    $scope.map = new google.maps.Map(document.getElementById('map'), $scope.mapOption);
    a = new CoordMapType(new google.maps.Size(256, 256));
    return $scope.map.overlayMapTypes.insertAt(0, a);
  };
  return google.maps.event.addDomListener(window, 'load', function(){
    return $scope.$apply(function(){
      return $scope.init();
    });
  });
};