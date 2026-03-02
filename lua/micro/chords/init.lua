local key_events = {hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}
local function parse_line(line)
  _G.assert((nil ~= line), "Missing argument line on fnl/micro/chords/init.fnl:6")
  if (4 == #line) then
    return line
  elseif "else" then
    return {line[1], line[2], {}, line[3]}
  else
    return nil
  end
end
local function make_chorder(chord_tree, _3fsubscriber)
  _G.assert((nil ~= chord_tree), "Missing argument chord-tree on fnl/micro/chords/init.fnl:19")
  local subscriber = _3fsubscriber
  local key_set = chord_tree
  local chord = {}
  local state = "init"
  local exit_status = nil
  local hydra = nil
  local hydra_chord = nil
  local tap = nil
  local function emit_update()
    if subscriber then
      return subscriber({"update", key_set, chord})
    else
      return nil
    end
  end
  local function emit_done(status)
    _G.assert((nil ~= status), "Missing argument status on fnl/micro/chords/init.fnl:40")
    if subscriber then
      return subscriber({"done", status})
    else
      return nil
    end
  end
  local function stop(status)
    _G.assert((nil ~= status), "Missing argument status on fnl/micro/chords/init.fnl:44")
    exit_status = status
    state = "exiting"
    return nil
  end
  local function exit()
    emit_done(exit_status)
    return tap:stop()
  end
  local function execute(line)
    _G.assert((nil ~= line), "Missing argument line on fnl/micro/chords/init.fnl:53")
    local _local_4_ = parse_line(line)
    local _ = _local_4_[1]
    local description = _local_4_[2]
    local opts = _local_4_[3]
    local action_or_set = _local_4_[4]
    local _5_ = type(action_or_set)
    if (_5_ == "table") then
      if opts.hydra then
        hydra = action_or_set
        hydra_chord = {table.unpack(chord)}
      else
      end
      key_set = action_or_set
      return emit_update()
    elseif (_5_ == "function") then
      if hydra then
        key_set = hydra
        chord = {table.unpack(hydra_chord)}
        emit_update()
      elseif "else" then
        stop("complete")
      else
      end
      return action_or_set()
    else
      return nil
    end
  end
  local function on_keypress(event)
    _G.assert((nil ~= event), "Missing argument event on fnl/micro/chords/init.fnl:76")
    local is_repeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
    if (is_repeat ~= 0) then
      return true
    else
    end
    local key_code = event:getKeyCode()
    local event_type = event:getType()
    if (state == "init") then
      state = "running"
      if (hs.eventtap.event.types.keyUp == event_type) then
        return false
      else
      end
    else
    end
    if (state == "running") then
      if (hs.eventtap.event.types.keyUp == event_type) then
        return true
      else
      end
    else
    end
    if (state == "exiting") then
      if (hs.eventtap.event.types.keyUp == event_type) then
        exit()
      else
      end
      return true
    else
    end
    if (key_code == 53) then
      stop("escape")
      return true
    else
    end
    local char = event:getCharacters(true)
    table.insert(chord, char)
    local line
    local function _17_(line0)
      return (char == (line0)[1])
    end
    line = hs.fnutils.find(key_set, _17_)
    if not line then
      stop("invalid")
      return true
    else
    end
    execute(line)
    return true
  end
  tap = hs.eventtap.new(key_events, on_keypress)
  tap:start()
  emit_update()
  return {}
end
return {["make-chorder"] = make_chorder}
