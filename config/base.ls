require! <[coord ./moeacgs ./tgos]>

config = do
  get: (type, name) -> 
    if !config[type] or !config[type][name] => return undefined
    src = config[type][name]
    ret = config[type]base! 
      ..config <<< (src.config or {})
      ..form <<< (src.form or {})
      ..name = name
  default:
    locate: (v, ll1, ll2, size) -> 
    base: -> {}

config <<< {
  moeacgs, tgos
}

module.exports = config

# sample usage:
# c = config.get "moeacgs", "cityusage"
