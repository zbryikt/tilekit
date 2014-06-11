require! <[fs pngjs]>
IMGDIR = "web/img/flood"
shrink-only = false
[Z-MIN, Z-MAX] = [12, 18]

if process.argv.length < 3 =>
  console.log "usage: lsc synth.ls [directory] [Z-MIN] [Z-MAX]"
  console.log "e.g., lsc download.ls web/img/cityusage 12 18"
  process.exit 0

IMGDIR = process.argv.2
if process.argv.length > 3 => Z-MIN = process.argv.3
if process.argv.length > 4 => Z-MAX = process.argv.4

expandable = ->
  [z, x, y] = [it.0 + 1,  it.1 * 2, it.2 * 2]
  if z > Z-MAX or it.0 < Z-MIN => return false
  for dx from 0 to 1
    for dy from 0 to 1
      if fs.exists-sync("#IMGDIR/#z/#{x + dx}/#{y + dy}.png") => return false
  return true

expand = (src, cb, ext) ->
  [zw, xw, yw] = src
  filename = "#IMGDIR/#zw/#xw/#yw.png"
  console.log "expand #filename"
  fs.createReadStream filename .pipe(new pngjs.PNG filtertype: 4)
    .on \parsed, ->
      for xi from 0 to 1
        for yi from 0 to 1
          png = new pngjs.PNG filtertype: 4, width: 256, height: 256
          empty = true
          for xs from 0 til 128
            for ys from 0 til 128
              idx = (ys + yi * 128) * @width + xs + xi * 128
              for j from 0 til 4
                jdx = (ys * 2 + parseInt(j / 2)) * 256 + xs * 2 + (j % 2)
                for i from 0 til 4
                  png.data[jdx * 4 + i] = @data[idx * 4 + i]
                  if png.data[jdx * 4 + i] => empty = false
          if empty => continue
          if !(fs.exists-sync "#IMGDIR/#{zw + 1}") => fs.mkdir-sync "#IMGDIR/#{zw + 1}"
          if !(fs.exists-sync "#IMGDIR/#{zw + 1}/#{2 * xw + xi}") => fs.mkdir-sync "#IMGDIR/#{zw + 1}/#{2 * xw + xi}"
          outfile = "#IMGDIR/#{zw + 1}/#{2 * xw + xi}/#{2 * yw + yi}.png"
          png.pack!pipe fs.createWriteStream outfile
          ext [zw + 1, 2 * xw + xi, 2 * yw + yi]
      cb!

shrinkable = ->
  [z, x, y] = [it.0 - 1,  parseInt(it.1/2), parseInt(it.2/2)]
  if z < Z-MIN or it.0 > Z-MAX => return false
  if fs.exists-sync("#IMGDIR/#z/#x/#y.png") => return false
  return true

_shrink = (png, file, dx, dy, cb) ->
  if !fs.exists-sync(file) => 
    for x from 0 til 256 by 2
      for y from 0 til 256 by 2
        for i from 0 til 4
          png.data[((dy + (y/2)) * 256 + dx + x/2) * 4 + i] = 0
    return cb!
  fs.createReadStream file .pipe(new pngjs.PNG filtertype: 4) .on \parsed ->
    for x from 0 til 256 by 2
      for y from 0 til 256 by 2
        for i from 0 til 4
          png.data[((dy + (y/2)) * 256 + dx + x/2) * 4 + i] = @data[(y * @width + x) * 4 + i]
    cb!


shrink = (src, cb, ext) ->
  [zw, xw, yw] = [src.0, src.1 - (src.1 % 2), src.2 - (src.2 % 2)]
  console.log "shrink #IMGDIR/#zw/#xw/#yw.png"
  png = new pngjs.PNG filtertype: 4, width: 256, height: 256
  png.mutex = 0
  for dx from 0 to 1
    for dy from 0 to 1
      infile = "#IMGDIR/#zw/#{xw + dx}/#{yw + dy}.png"
      _shrink png, infile, dx * 128, dy * 128, ->
        png.mutex++
        if png.mutex == 4 =>
          outfile = "#IMGDIR/#{zw - 1}/#{xw / 2}/#{yw / 2}.png"
          if !(fs.exists-sync "#IMGDIR/#{zw - 1}") => fs.mkdir-sync "#IMGDIR/#{zw - 1}"
          if !(fs.exists-sync "#IMGDIR/#{zw - 1}/#{xw / 2}") => fs.mkdir-sync "#IMGDIR/#{zw - 1}/#{xw / 2}"
          png.pack!pipe fs.createWriteStream outfile
          ext [zw - 1, xw / 2, yw / 2]
          cb!

# get all tiles
files = {}
for z in fs.readdir-sync IMGDIR =>
  z = parseInt(z)
  if isNaN z => continue
  if z > 14 and shrink-only => continue
  if z < Z-MIN or z > Z-MAX => continue
  if !fs.statSync("#IMGDIR/#z")isDirectory! => continue
  for x in fs.readdir-sync "#IMGDIR/#z" =>
    if !fs.statSync("#IMGDIR/#z/#x")isDirectory! => continue
    for file in fs.readdir-sync "#IMGDIR/#z/#x" =>
      ret = /^(\d+)\.png$/g.exec file
      if !ret => continue
      files.[][z].push([z, x, ret.1]map -> parseInt(it))

async-examine = -> set-timeout (-> examine!), 0
add-to-queue = -> files.[][it.0].push it

# check every file for possibility to expand or shrink
examine = ->
  keys = [k for k of files]
  keys.sort (a,b) -> parseInt(b) - parseInt(a)
  len = keys.map(-> files[it]length)reduce(((a,b) -> a + b), 0)
  if !len => return 
  keys = keys.filter -> files[it]length
  src = files[keys.0]0
  if !(len % 100) => console.log "#{len} remains..."
  files[keys.0]splice(0,1)
  if expandable(src) and !shrink-only => return expand src, async-examine, add-to-queue
  if shrinkable(src) => return shrink src, async-examine, add-to-queue
  set-timeout (-> examine!), 0

len = [k for k of files]map(-> files[it]length)reduce(((a,b) -> a + b), 0)
console.log "total #{len} tiles"

examine!
