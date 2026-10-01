local M = {}

-- terafox (https://github.com/EdenEast/nightfox.nvim/blob/main/lua/nightfox/palette/terafox.lua)
local colors = {
  model = "#5a93aa", -- blue.base
  effort = "#ad5c7c", -- magenta.base
  dir = "#a1cdd8", -- cyan.base
  branch = "#7aa4a1", -- green.base
  text = "#e6eaea", -- fg1
  warn = "#fda47f", -- yellow.base
  crit = "#e85c51", -- red.base
  dim = "#587b7b", -- fg3
}

local function paint(hex, text)
  local r, g, b = hex:match("#(%x%x)(%x%x)(%x%x)")
  return string.format("\27[38;2;%d;%d;%dm%s\27[0m", tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), text)
end

local function dig(t, ...)
  for _, key in ipairs({ ... }) do
    if type(t) ~= "table" then
      return nil
    end
    t = t[key]
  end
  return t
end

function M.duration(ms)
  local s = math.floor(ms / 1000)
  if s < 60 then
    return s .. "s"
  elseif s < 3600 then
    return math.floor(s / 60) .. "m"
  end
  return string.format("%dh%02dm", math.floor(s / 3600), math.floor(s / 60) % 60)
end

local function context_color(pct)
  if pct >= 80 then
    return colors.crit
  elseif pct >= 60 then
    return colors.warn
  end
  return colors.text
end

-- input は Claude Code が statusLine コマンドに渡す JSON．branch は呼び出し側が git から取る
function M.render(input, branch)
  local segments = {}
  local function add(color, text)
    segments[#segments + 1] = paint(color, text)
  end

  local model = dig(input, "model", "display_name")
  if model then
    -- Why: "(1M context)" のような補足は ctx の数値と重なるうえ行を圧迫する
    add(colors.model, (model:gsub("%s*%b()", "")))
  end

  local effort = dig(input, "effort", "level")
  if effort then
    add(colors.effort, effort)
  end

  local dir = dig(input, "workspace", "current_dir") or input.cwd
  if dir then
    local place = paint(colors.dir, dir:match("([^/]+)/*$") or dir)
    if branch and branch ~= "" then
      place = place .. " " .. paint(colors.branch, "⎇ " .. branch)
    end
    segments[#segments + 1] = place
  end

  local pct = dig(input, "context_window", "used_percentage")
  if pct then
    add(context_color(pct), string.format("ctx %d%%", math.floor(pct + 0.5)))
  end

  local ms = dig(input, "cost", "total_duration_ms")
  if ms then
    add(colors.dim, M.duration(ms))
  end

  local usd = dig(input, "cost", "total_cost_usd")
  if usd then
    add(colors.dim, string.format("$%.2f", usd))
  end

  return table.concat(segments, paint(colors.dim, " · "))
end

return M
