require! <[fs ./range]>

if process.argv.length < 3 =>
  console.log "usage: lsc vector.ls [directory]"
  console.log "e.g., lsc download.ls web/img/cityusage"
  console.log "  a vector.json(for ajax) and vector.js(for jsonp) will both be generated at target directory."
  process.exit 0

IMGDIR = process.argv.2
name = IMGDIR.split(\/)filter(->it)[* - 1]
name = name.replace /[. -]/g, "_"

recurse-dir = (root) ->
  if !fs.exists-sync root => return []
  if !fs.statSync(root)isDirectory! => return if /\.png$/.exec root => [root] else []
  files = ["#root/#f" for f in fs.readdir-sync(root)]
  ret = []
  for file in files
    ret ++= recurse-dir file
  return ret

list = recurse-dir IMGDIR

pat = /(\d+)\/(\d+)\/(\d+).png/
bitvector = {}
for file in list
  ret = pat.exec file
  if !ret => continue
  [z,x,y] = ret[1 to 3]map -> parseInt it
  if !range[z] and z <= 11 => continue
  bitvector[z] ?= {}
  if !bitvector[z][y] =>
    if z >= 12 =>
      o = z - 11
      oy = y .>>. o
      if !range.11[oy] => continue
      min = Math.min.apply(null, ((range.11[oy]2 or []) ++ [range.11[oy]0])) .<<. o
      max = Math.max.apply(null, ((range.11[oy]2 or []) ++ [range.11[oy]1])) .<<. o
      len = Math.ceil((max - min) / 32)
    else
      if !range[z][y] => continue
      min = Math.min.apply(null, ((range[z][y]2 or []) ++ [range[z][y]0]))
      max = Math.max.apply(null, ((range[z][y]2 or []) ++ [range[z][y]1]))
      len = Math.ceil((max - min) / 32)
    bitvector[z][y] = [min, max, [0 for i from 0 til len]]
  bv = bitvector[z][y]
  dx = (x - bv.0)
  o = parseInt(dx / 32)
  v = 1 .<<. (31 - parseInt(dx % 32))
  bv.2[o] .|.= v

fs.write-file-sync "#IMGDIR/vector.json", JSON.stringify bitvector
fs.write-file-sync "#IMGDIR/vector.js", "var #name = { bv: #{JSON.stringify(bitvector)}, check: function(z, x, y){ var yv, dx, o, v; if (!this.bv || !this.bv[z] || !this.bv[z][y]) { return false; } yv = this.bv[z][y]; if (yv[0] > x || yv[1] < x) { return false; } dx = x - yv[0]; o = parseInt(dx / 32); v = 1 << 31 - dx % 32; return yv[2][o] & v ? true : false; }}; var tilevector = #name;"

