// Generated by LiveScript 1.2.0
var TileLayer, module;
TileLayer = function(config){
  var this$ = this;
  import$(this, config);
  this.idx = TileLayer.idx || 0;
  TileLayer.idx = (TileLayer.idx || 0) + 1;
  if (typeof this.visible === "undefined") {
    this.visible = true;
  }
  if (typeof this.enabled === "undefined") {
    this.enabled = true;
  }
  if (this.url) {
    this.url = this.url.replace(/\/$/, "");
  }
  this.tileSize = new google.maps.Size(256, 256);
  this.vector = null;
  if (this.bv) {
    $.ajax({
      url: this.bv,
      dataType: 'json'
    }).success(function(d){
      return this$.vector = d;
    });
  }
  this.map.overlayMapTypes.setAt(this.idx, null);
  if (this.visible) {
    this.map.overlayMapTypes.insertAt(this.idx, this);
  }
  google.maps.event.addListener(this.map, 'zoom_changed', function(z){
    return this$.onZoomChanged(this$.map.getZoom());
  });
  return this;
};
import$(TileLayer.prototype, {
  onZoomChanged: function(z){
    if (typeof this.showLv === "undefined") {
      return;
    }
    if (z < this.showLv) {
      return this.disable();
    } else if (!this.enabled) {
      return this.enable();
    }
  },
  enable: function(){
    this.enabled = true;
    return this.toggle(this.visible);
  },
  disable: function(){
    this.enabled = false;
    return this.toggle(this.visible);
  },
  toggle: function(visible){
    this.visible = typeof visible === "undefined" ? !this.visible : visible;
    return this.map.overlayMapTypes.setAt(this.idx, this.visible && this.enabled ? this : null);
  },
  getTile: function(c, z, doc){
    var x, y, div, x$, ref$, dx, dy;
    x = c.x, y = c.y;
    div = doc.createElement('div');
    x$ = div.style;
    x$.width = this.tileSize.width + "px";
    x$.height = this.tileSize.height + "px";
    x$.opacity = this.opacity + "";
    x$.backgroundPosition = "center center";
    x$.backgroundAttachment = "no-repeat";
    if (this.vector && !check(this.vector, z, x, y)) {
      if (!(this.extend && check(this.vector, z - 1, parseInt(x / 2), parseInt(y / 2)))) {
        return div;
      }
      ref$ = [(x % 2) * 256, (y % 2) * 256], dx = ref$[0], dy = ref$[1];
      ref$ = [z - 1, parseInt(x / 2), parseInt(y / 2)], z = ref$[0], x = ref$[1], y = ref$[2];
      div.style.backgroundPosition = "-" + dx + "px -" + dy + "px";
      div.style.backgroundSize = "512px 512px";
    }
    div.style.backgroundImage = this.getimg
      ? "url(" + this.getimg(z, x, y) + ")"
      : "url(" + this.url + "/" + z + "/" + x + "/" + y + ".png)";
    return div;
  }
});
module == null && (module = {});
module.exports = TileLayer;
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}