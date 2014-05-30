#require! <[coord ./moeacgs ./tgos]>
require! <[coord ./nlsc]>

# config protocol
# { form: {...}, config: { 
#     url: ...
#     X: ?, Y: ?, Z-MAX: ?, Z-MIN: ?, TILE-POWER: ?, SIZE: ?
#   }, 
#   locate: (c, ll1, ll2, size, x, y, z): -> ...
# }
config = do
  get: (name) ->
    if !config.item[name] => return undefined
    c = config.item[name]
    t = config.type[c.type]
    ret = t.init c
    ret.name = name
    ret

  locate: (c, ll1, ll2, size, x, y, z) ->
    c.type.locate c, ll1, ll2, size, x, y, z

  type: {}
  item: {}

for item in [nlsc] #[moeacgs, tgos]
  config.type <<< item.type
  config.item <<< item.item

module.exports = config
