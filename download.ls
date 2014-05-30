require! <[fs util pngjs coord request ./range ./tile]>
config = require \./config/base

DSTDIR = "img"

if process.argv.length < 3 =>
  console.log "usage: lsc download.ls [name]"
  console.log "e.g., lsc download.ls cityusage_wmts"
  process.exit 0

wms-name = process.argv.2

useconfig = config.get wms-name
{X, Y, Z, Z-MIN, Z-MAX, TILE-POWER, SIZE} = useconfig.config
Z-MIN = parseInt(process.argv.3) or Z-MIN
Z-MAX = parseInt(process.argv.4) or Z-MAX
TILE-RATE = 2 ** TILE-POWER
if !SIZE => SIZE = tile.TILE_SIZE * TILE-RATE
X = parseInt(process.argv.5) or X
Y = parseInt(process.argv.6) or Y
Z = parseInt(process.argv.7) or Z
console.log "Use Configuration: #{wms-name} (#{useconfig.type})"
console.log "Start Coordinate: #X #Y #Z"
console.log "Tile Per Image: #{TILE-RATE * TILE-RATE}, size: #SIZE * #SIZE"

list = []
blank = fs.read-file-sync \blank.png
getname = (type,o) -> "#DSTDIR/#{type}/#{o.z}-#{o.x}-#{o.y}.png"
makeurl = (c) -> c.config.url + "?" + (["#k=#v" for k,v of c.form]join "&")

breakdown = (x, y, z, name) ->
  if z > Z-MAX => return
  if range[z] and (!range[z][y] or ((x < range[z][y]0 or x > range[z][y]1) and !(x in (range[z][y][2] or [])))) => return
  ll1 = tile.t2ll x    , y    , z
  ll2 = tile.t2ll x + 1, y + 1, z
  obj = {z, x, y, ll1, ll2}
  filename = getname(name, obj)
  if fs.exists-sync(filename) and fs.statSync(filename)size==0 => fs.unlinkSync filename
  if z >=Z-MIN and !fs.exists-sync(filename) => list.push obj
  breakdown x * 2    , y * 2    , z + 1, name
  breakdown x * 2 + 1, y * 2    , z + 1, name
  breakdown x * 2    , y * 2 + 1, z + 1, name
  breakdown x * 2 + 1, y * 2 + 1, z + 1, name

breakdown X, Y, Z, useconfig.name
console.log "tile count:"
for [z,len] in [1 to 18]map((z)-> [z,list.filter(-> it.z == z)length])filter(->it.1)
  console.log "  level #z : #len"
console.log "total #{list.length} to fetch"

isempty = (png, width, height) ->
  for y from 0 til height
    for x from 0 til width
      if png.data[( y * width + x ) * 4 + 3] => return false
  return true

download = (opt) ->
  if !fs.exists-sync("#DSTDIR") => fs.mkdir-sync "#DSTDIR"
  if !fs.exists-sync("#DSTDIR/#{opt.name}") => fs.mkdir-sync "#DSTDIR/#{opt.name}"
  while true
    if list.length == 0 => return
    item = list.splice(0,1)0
    name = getname opt.name, item
    if !fs.exists-sync(name) => break
  console.log "(#{list.length}) get #name..."
  opt.locate item.ll1, item.ll2, SIZE, item.x, item.y, item.z
  r = fs.create-write-stream "#name", autoClose: true
  r.on \close -> 
    <- set-timeout _, 0
    fs.createReadStream name .pipe(new pngjs.PNG filtertype: 4)
    .on \parsed, -> if isempty(@,SIZE,SIZE) => fs.writeFileSync name, blank
    set-timeout (-> download opt),Math.random!*900 + 200
  request makeurl(opt) .pipe r

download useconfig

