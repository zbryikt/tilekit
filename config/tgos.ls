require! <[coord]>
module.exports = do
  type:
    tgos:
      config:
        url: \http://gis.tgos.nat.gov.tw/TGQuery/TGQuery.ashx
        X: 6
        Y: 3
        Z: 3
        Z-MIN: 11
        Z-MAX: 11
        TILE-POWER:  8
      form: do
        op: \image
        res: \HAZARD_FLOOD_P.cfg
        keystr: \Pkce9bTqsnJMR4ILNemlEg%3D%3D
      init: (opt) ->
        c = {} <<< @config <<< opt.config
        f = {} <<< @form <<< opt.form
        {type: opt.type, config: c, form: f, locate: @locate}
      locate: (ll1, ll2, size, x, y, z) ->
      locate: (ll1, ll2, size, x, y, z) ->
        [x1,y1] = coord.to-twd97 {lat: ll1.lat!, lng: ll1.lng!}
        [x2,y2] = coord.to-twd97 {lat: ll2.lat!, lng: ll2.lng!}
        @form <<< do
          Left: x1
          Top: y1
          Right: x2
          Bottom: y2
          Width: size
          Height: size
  item:
    flood: 
      form: 
        layer: \dbo.1DR600_201208A
        keystr: \Pkce9bTqsnJMR4ILNemlEg%3D%3D # need update every time 

