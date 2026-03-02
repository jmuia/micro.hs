local notify
local function _1_(title, text)
  return hs.notify.new({title = title, informativeText = text}):send()
end
notify = {send = _1_}
local function make_watcher(path)
  _G.assert((nil ~= path), "Missing argument path on fnl/micro/reload/init.fnl:7")
  local function on_reload(paths)
    _G.assert((nil ~= paths), "Missing argument paths on fnl/micro/reload/init.fnl:8")
    local changed = false
    for i, path0 in ipairs(paths) do
      changed = (changed or not string.find(path0, ".git"))
    end
    if changed then
      hs.reload()
      hs.notify.withdrawAll()
      return notify.send("Config watcher", "Reloading configuration")
    else
      return nil
    end
  end
  local hs_watcher = hs.pathwatcher.new(path, on_reload)
  local function start()
    return hs_watcher:start()
  end
  return {start = start}
end
return {["make-watcher"] = make_watcher}
