require! <[fs pngjs]>

IMGDIR = \img/cityusage/
DESDIR = \web/img/cityusage/
files = [n.replace(\.png, "")split(\-)map(->parseInt(it)) for n in (fs.readdir-sync(IMGDIR)filter(->/\.png/exec it))]
TILE_POW = 3
TILE_RATE = 8


range = do
 z: min: Math.min.apply(null, [it.0 for it in files]), max: Math.max.apply(null, [it.0 for it in files])
 x: min: 0, max: 0
 y: min: 0, max: 0
 bit: {}
 idx: (x, y, z) ->
   w = 1 .<<. (z - @z.min)
   x -= @x.min .<<. (z - @z.min)
   y -= @y.min .<<. (z - @z.min)
   y * w + x
 set: (x,y,z,ison) ->
   idx = @idx x,y,z
   i1 = parseInt(idx / 32)
   i2 = idx % 32
   size = 1 .<<. (z - @z.min)
   #console.log z, size * size / 32, i1, i2
   if !@bit[z] =>
     @bit[z] = new Array size * size / 32
     for i from 0 til size * size / 32
       @bit[z][i] = 0
   v = 1 .<<. i2
   if !ison =>
     v = ~v
     @bit[z][i1] = @bit[z][i1] .&. v
   else
     @bit[z][i1] = @bit[z][i1] .|. v

top-zoom = files.filter(-> it.0 == range.z.min)
range.x = min: Math.min.apply(null, [it.1 for it in top-zoom]), max: Math.max.apply(null, [it.1 for it in top-zoom])
range.y = min: Math.min.apply(null, [it.2 for it in top-zoom]), max: Math.max.apply(null, [it.2 for it in top-zoom])

build = (src, des, cb) ->
  ret = /\/([^-/]+)-([^-]+)-([^-]+).png/exec src
  if !ret => return cb!
  xw = parseInt(ret.2) * TILE_RATE
  yw = parseInt(ret.3) * TILE_RATE
  zw = parseInt(ret.1) + TILE_POW
  fs.createReadStream src .pipe(new pngjs.PNG filterType: 4)
    .on \parsed, ->
      empty = if @width == 1 => true else false
      for y1 from 0 til TILE_RATE
        for x1 from 0 til TILE_RATE
          xb = x1 * 256
          yb = y1 * 256
          v = 0
          if !empty =>
            for x from 0 til 256
              for y from 0 til 256
                for a from 0 til 4
                  v = v || @data[((yb + y) * @width + xb + x) * 4 + a]
                  if v => break
                if v => break
              if v => break

          range.set xw + x1, yw + y1, zw, v
          if !v => continue
          png = new pngjs.PNG filterType: 4, width: 256, height: 256
          for x from 0 til 256
            for y from 0 til 256
              for a from 0 til 4
                png.data[(y * 256 + x) * 4 + a] = @data[((yb + y) * @width + xb + x) * 4 + a]
          out = "#des/#zw/#{xw + x1}/#{yw + y1}.png"
          if !fs.exists-sync des => fs.mkdir-sync des
          if !fs.exists-sync "#des/#zw" => fs.mkdir-sync "#des/#zw"
          if !fs.exists-sync "#des/#zw/#{xw + x1}" => fs.mkdir-sync "#des/#zw/#{xw + x1}"
          png.pack!pipe fs.createWriteStream out
      cb!

readallfile = (root) ->
  ret = {}
  files = fs.readdir-sync root
  for f in files => 
    path = "#root/#f"
    if !fs.statSync(path)isDirectory! =>
      ret[f] = {}
      continue
    ret[f] = readallfile path
  ret

console.log "build des file hash.."
deshash = readallfile DESDIR

files = ["#IMGDIR/#f" for f in fs.readdir-sync(IMGDIR)]filter -> /\.png$/exec it
console.log "total #{files.length}, filter built images..."
count = 0
files = files.filter ->
  count := count + 1
  if !(count%100) => console.log "#count / #{files.length}"
  ret = /([^-/]+)-([^-]+)-([^-]+).png$/g.exec it
  if !ret => return false
  [z,x,y] = ret[1 to 3]map -> parseInt(it)
  #ret = ["#DESDIR/#{z + TILE_POW}/#{x * TILE_RATE + (i % TILE_RATE)}/#{y * TILE_RATE + parseInt(i / TILE_RATE)}.png" for i from 0 to (TILE_RATE**2)]filter -> fs.exists-sync it
  #if !ret.length => return true
  victim = false
  for i from 0 til (TILE_RATE**2)
    [tz, tx, ty] = [z + TILE_POW, x * TILE_RATE + (i % TILE_RATE), "#{y * TILE_RATE + parseInt(i / TILE_RATE)}.png"]
    if !deshash[tz] or !deshash[tz][tx] or !deshash[tz][tx][ty] =>
      victim = true
      break
  if victim => return true
  false

console.log "total #{files.length} files to parse"
#console.log files.join \\n

worker = ->
  if files.length == 0 => 
    fs.write-file-sync "bits.json", JSON.stringify(range.bit)
    console.log "done"
    return
  file = files.splice(0,1)0
  console.log files.length, file
  build file, DESDIR, (-> set-timeout((-> worker!), 0 ))

worker!
