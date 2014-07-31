require! <[coord]>

module.exports = do
  type:
    wmts:
      config:
        url: \http://maps.nlsc.gov.tw/S_Maps/wmts
      form:
        SERVICE: \WMTS
        REQUEST: \GetTile
        VERSION: \1.0.0
        STYLE: \_null
        TILEMATRIXSET: \EPSG:3857
        TILEMATRIX: ""
        FORMAT: \image/png
      init: (opt) ->
        c = {} <<< @config <<< opt.config
        f = {} <<< @form <<< opt.form
        {type: opt.type, config: c, form: f, locate: @locate}
      locate: (ll1, ll2, size, x, y, z) ->
        @form
          ..TILEMATRIX = "#{@form.TILEMATRIXSET}:#z"
          ..TILEROW = y
          ..TILECOL = x

  item:
    # from http://tgos.nat.gov.tw/tgos/Web/Service/TGOS_Service_Detail.aspx?SID=6777
    # live preview: http://maps.nlsc.gov.tw/
    # alternative version: http://luz.tcd.gov.tw/
    # tile example:
    # http://59.125.100.80/tcdmap/rest/services/TCDGIS/URBAN_LANDUSE_ZONE/MapServer/tile/10/10675/8375
    # http://maps.nlsc.gov.tw/S_Maps/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=URBAN
    #  &STYLE=_null&TILEMATRIXSET=EPSG:3857&TILEMATRIX=EPSG:3857:18&TILEROW=112219&TILECOL=219566&FORMAT=image/png
    # check http://maps.nlsc.gov.tw/S_Maps/wmts for service list, although land use is not inside.
   
    landusage_wmts:
      type: \wmts
      config:
        X: 6
        Y: 3
        Z: 3
        Z-MIN: 12
        Z-MAX: 18
        TILE-POWER:  0
        SIZE: 256
      form:
        LAYER: \nURBAN
        
    cityusage_wmts:
      type: \wmts
      config:
        X: 6
        Y: 3
        Z: 3
        Z-MIN: 12
        Z-MAX: 18
        TILE-POWER:  0
        SIZE: 256
      form:
        LAYER: \URBAN

