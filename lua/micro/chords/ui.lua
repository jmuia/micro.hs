local max_cols = 5
local cell_width = 125
local cell_height = 20
local x_padding = 10
local y_padding = 2
local x_margin = 30
local y_margin = 14
local key_font_face = "Helvetica Bold"
local name_font_face = "Iosevka"
local font_size = 14
local key_width = 10
local text_padding_t = 1
local key_padding_r = 8
local screen_offset_y = 35
local background_color = {red = 1, green = 1, blue = 1, alpha = 1}
local foreground_color = {red = 0, green = 0, blue = 0, alpha = 1}
local shadow_color = {red = 0, green = 0, blue = 0, alpha = (1 / 3)}
local accent_color = {red = 0.388, green = 0.356, blue = 1, alpha = 1}
local container_border_radius = 5
local chord_report_offset_y = 20
local chord_report_x_margin = 12
local chord_report_height = 30
local chord_report_text_padding_t = 6
local chord_report_key_padding_r = 6
local function cmp_semi_case_insensitive(_1_, _3_)
  local _arg_2_ = _1_
  local a = _arg_2_[1]
  local _ = _arg_2_[2]
  local _arg_4_ = _3_
  local b = _arg_4_[1]
  local _0 = _arg_4_[2]
  if (string.upper(a) == string.upper(b)) then
    return ((a ~= string.upper(a)) and (b == string.upper(b)))
  elseif "else" then
    return (string.upper(a) < string.upper(b))
  else
    return nil
  end
end
local function build_ui(data, chord)
  _G.assert((nil ~= chord), "Missing argument chord on fnl/micro/chords/ui.fnl:41")
  _G.assert((nil ~= data), "Missing argument data on fnl/micro/chords/ui.fnl:41")
  local cols = math.min(#data, max_cols)
  local rows = math.ceil((#data / max_cols))
  local container_width = ((cols * cell_width) + ((cols - 1) * x_padding) + (2 * x_margin))
  local container_height = ((rows * cell_height) + ((rows - 1) * y_padding) + (2 * y_margin))
  local canvas_margin = 20
  local canvas = hs.canvas.new({w = (container_width + (2 * canvas_margin)), h = (container_height + (2 * canvas_margin) + chord_report_height + chord_report_offset_y)})
  local frame = hs.screen.mainScreen():frame()
  canvas:topLeft({x = ((frame.w - container_width - (2 * canvas_margin)) / 2), y = ((frame.h + canvas_margin) - screen_offset_y - container_height - chord_report_height - chord_report_offset_y)})
  canvas:level("overlay")
  if (#chord > 0) then
    local chord_report_width = ((2 * chord_report_x_margin) + (#chord * key_width) + ((#chord - 1) * chord_report_key_padding_r))
    local chord_report_x = (canvas_margin + ((container_width - chord_report_width) / 2))
    local chord_report_y = canvas_margin
    canvas:insertElement({type = "rectangle", action = "fill", roundedRectRadii = {xRadius = container_border_radius, yRadius = container_border_radius}, fillColor = background_color, frame = {x = chord_report_x, y = chord_report_y, h = chord_report_height, w = chord_report_width}, withShadow = true, shadow = {blurRadius = 10.0, color = shadow_color, offset = {h = -2, w = 1}}})
    for n, key in ipairs(chord) do
      local c = (n - 1)
      local _6_
      if (key == string.upper(key)) then
        _6_ = 1
      else
        _6_ = 0
      end
      local _8_
      if (key == string.upper(key)) then
        _8_ = 2
      else
        _8_ = 0
      end
      canvas:insertElement({type = "text", action = "fill", frame = {x = (chord_report_x + chord_report_x_margin + (c * key_width) + (c * chord_report_key_padding_r)), y = (chord_report_y + chord_report_text_padding_t), w = key_width, h = chord_report_height}, text = hs.styledtext.new(key, {font = {name = name_font_face, size = font_size}, color = foreground_color, underlineStyle = _6_, baselineOffset = _8_, paragraphStyle = {alignment = "center"}})})
    end
  else
  end
  canvas:insertElement({type = "rectangle", action = "fill", roundedRectRadii = {xRadius = container_border_radius, yRadius = container_border_radius}, fillColor = background_color, frame = {x = canvas_margin, y = (canvas_margin + chord_report_height + chord_report_offset_y), h = container_height, w = container_width}, withShadow = true, shadow = {blurRadius = 10.0, color = shadow_color, offset = {h = -2, w = 1}}})
  table.sort(data, cmp_semi_case_insensitive)
  for n, entry in ipairs(data) do
    local key = entry[1]
    local name = entry[2]
    local opts
    if (4 == #entry) then
      opts = entry[3]
    else
      opts = {}
    end
    local display_key = (opts.display or key)
    local c = math.floor(((n - 1) / max_cols))
    local r = ((n - 1) % max_cols)
    local cell_x = (canvas_margin + x_margin + (r * cell_width) + (r * x_padding))
    local cell_y = (canvas_margin + chord_report_height + chord_report_offset_y + y_margin + (c * cell_height) + (c * y_padding))
    local _12_
    if (key == string.upper(key)) then
      _12_ = 2
    else
      _12_ = 0
    end
    local _14_
    if (key == string.upper(key)) then
      _14_ = 3
    else
      _14_ = 0
    end
    canvas:insertElement({type = "text", action = "fill", frame = {x = cell_x, y = (cell_y + text_padding_t + -1), w = key_width, h = cell_height}, text = hs.styledtext.new(display_key, {font = {name = (name_font_face .. " Bold"), size = (2 + font_size)}, color = accent_color, underlineStyle = _12_, baselineOffset = _14_})})
    canvas:insertElement({type = "text", text = name, action = "fill", frame = {x = (cell_x + key_width + key_padding_r), y = (cell_y + text_padding_t), w = (cell_width - key_width - key_padding_r), h = cell_height}, textAlignment = "left", textColor = foreground_color, textFont = name_font_face, textSize = font_size})
  end
  return canvas
end
local function make_chorder_ui()
  local canvas = nil
  local function on_event(event)
    _G.assert((nil ~= event), "Missing argument event on fnl/micro/chords/ui.fnl:200")
    if ((_G.type(event) == "table") and (event[1] == "update") and (nil ~= event[2]) and (nil ~= event[3])) then
      local data = event[2]
      local chord = event[3]
      if canvas then
        canvas:hide(0)
      else
      end
      canvas = build_ui(data, chord)
      local function _17_()
        if canvas then
          return 0
        else
          return 0.15
        end
      end
      return canvas:show(_17_())
    elseif ((_G.type(event) == "table") and (event[1] == "done") and (nil ~= event[2])) then
      local status = event[2]
      if canvas then
        canvas:hide(0.15)
        canvas = nil
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  return {["on-event"] = on_event}
end
return {["make-chorder-ui"] = make_chorder_ui}
