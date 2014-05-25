require! <[coord]>

module.exports = do
  locate: (v, ll1, ll2, size) ->
    if v.config.twd =>
      [x1,y1] = coord.to-twd97 {lat: ll1.lat!, lng: ll1.lng!}
      [x2,y2] = coord.to-twd97 {lat: ll2.lat!, lng: ll2.lng!}
      v.form.BBOX = "#{x1},#{y2},#{x2},#{y1}"
    else =>
      v.form.BBOX = "#{ll1.lng!},#{ll2.lat!},#{ll2.lng!},#{ll1.lat!}"
    v.form.width = size
    v.form.height = size
  base: ->
    ret = do
      config:
        # url: \http://gwh.moeacgs.gov.tw/geo4oracle/mapagent/mapagent.fcgi # with domain
        url: \http://210.69.81.220/geo4oracle/mapagent/mapagent.fcgi        # with ip
        twd: false
        X: 6
        Y: 3
        Z: 3
        Z-MIN: 13
        Z-MAX: 14
        TILE-POWER:  3
      form: do
        Request: "GetMap",
        SERVICE: "WMS",
        VERSION: "1.1.1",
        BGCOLOR: "0xFFFFFF",
        TRANSPARENT: "TRUE",
        SRS: "EPSG:4326",
        FORMAT: "image/png",
        LAYERS: ",WMS/LAYER/TW/G97_TW_DIPSLOPE_P_2013F",
        width: "768",
        height: "768",
        BBOX: "121.555665,25.083541,121.577723,25.092480"

  slope: 
    config:
      Z-MIN: 11
      Z-MAX: 14
      TILE-POWER: 4
    form: LAYERS: \,WMS/LAYER/TW/G97_TW_DIPSLOPE_P_2013F
  fault: 
    form: LAYERS: ',WMS/LAYER/TW/G97_TW_B1_L_2013F,WMS/LAYER/TW/G97_TW_B1_L_2013F_T'
  debrisflow: 
    form: LAYERS: \,WMS/LAYER/TW/G97_TW_DEBRISFLOW_P_2013F
  landslide: 
    form: LAYERS: \,WMS/LAYER/TW/G97_TW_LANDSLIDE_P_2013F
  cityusage: 
    config: 
      url: \http://ngis.tcd.gov.tw:8080/geoserver/wms
      twd: true
      Z-MAX: 15
    form: LAYERS: \LandUse, SRS: \EPSG:3826

