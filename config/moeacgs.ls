require! <[coord]>

module.exports = do
  type:
    mapagent:
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
      init: (opt) ->
        c = {} <<< @config <<< opt.config 
        f = {} <<< @form <<< opt.form 
        {type: opt.type, config: c, form: f, locate: @locate}
      locate: (ll1, ll2, size, x, y, z) ->
        if @config.twd =>
          [x1,y1] = coord.to-twd97 {lat: ll1.lat!, lng: ll1.lng!}
          [x2,y2] = coord.to-twd97 {lat: ll2.lat!, lng: ll2.lng!}
          @form.BBOX = "#{x1},#{y2},#{x2},#{y1}"
        else =>
          @form.BBOX = "#{ll1.lng!},#{ll2.lat!},#{ll2.lng!},#{ll1.lat!}"
        @form.width = size
        @form.height = size
  item:
    slope: 
      type: \mapagent
      config:
        Z-MIN: 11
        Z-MAX: 14
        TILE-POWER: 4
      form: LAYERS: \,WMS/LAYER/TW/G97_TW_DIPSLOPE_P_2013F
    fault: # 斷層
      type: \mapagent
      form: LAYERS: ',WMS/LAYER/TW/G97_TW_B1_L_2013F,WMS/LAYER/TW/G97_TW_B1_L_2013F_T'
    debrisflow: # 土石流分佈
      type: \mapagent
      form: LAYERS: \,WMS/LAYER/TW/G97_TW_DEBRISFLOW_P_2013F
    landslide: # 山崩潛勢
      type: \mapagent
      form: LAYERS: \,WMS/LAYER/TW/G97_TW_LANDSLIDE_P_2013F
    rock: # 落石潛勢
      type: \mapagent
      form: LAYERS: \,WMS/LAYER/TW/G97_TW_ROCK_P_2013F
    sutp: # 岩屑崩滑潛勢
      type: \mapagent
      form: LAYERS: \,WMS/LAYER/TW/G97_TW_SUTP_P_2013F
    depslide: # 岩體滑動復發潛勢
      type: \mapagent
      form: LAYERS: \,WMS/LAYER/TW/G97_TW_DEPSLIDE_P_2013F
    debrispoten: # 集水區土石流潛勢
      type: \mapagent
      form: LAYERS: \,WMS/LAYER/TW/G97_TW_DEBRISPOTEN_P_2013F
    hazard: # 重大崩坍範圍
      type: \mapagent
      form: LAYERS: \,WMS/LAYER/TW/G97_TW_HAZZONE_P_2013F
    dangerzone: # 各潛勢圖總和
      type: \mapagent
      config:
        Z-MIN: 11
        Z-MAX: 14
        TILE-POWER: 4
      form: LAYERS: ",WMS/LAYER/TW/G97_TW_LANDSLIDE_P_2013F,WMS/LAYER/TW/G97_TW_ROCK_P_2013F,WMS/LAYER/TW/G97_TW_SUTP_P_2013F,WMS/LAYER/TW/G97_TW_DEPSLIDE_P_2013F,WMS/LAYER/TW/G97_TW_DEBRISPOTEN_P_2013F,WMS/LAYER/TW/G97_TW_DIPSLOPE_P_2013F"
