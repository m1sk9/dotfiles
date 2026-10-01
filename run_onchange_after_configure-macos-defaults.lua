#!/usr/bin/env luajit
-- Why not Hammerspoon: hs.settings は Hammerspoon 自身のドメインしか扱えず，
-- 起動のたびに OS の設定を書き直すことにもなる．apply 時に一度だけ流せば足りる

local settings = {
  NSGlobalDomain = {
    KeyRepeat = 5,
    InitialKeyRepeat = 25,
    AppleShowAllExtensions = true,
    AppleInterfaceStyle = "Dark",
    ["com.apple.swipescrolldirection"] = false,
  },
  ["com.apple.dock"] = {
    autohide = true,
    magnification = true,
    tilesize = 21,
    largesize = 79,
    ["show-recents"] = false,
    -- 左下のホットコーナーで Mission Control
    ["wvous-bl-corner"] = 2,
    ["wvous-bl-modifier"] = 0,
  },
  ["com.apple.finder"] = {
    AppleShowAllFiles = true,
    CreateDesktop = false,
    FXPreferredViewStyle = "Nlsv",
    FXRemoveOldTrashItems = true,
  },
  ["com.apple.screencapture"] = {
    location = "~/Pictures/Screenshots",
    -- Why: サムネイル表示中はファイルの書き出しが待たされ，dot_hammerspoon の
    -- クリップボードへのコピーも数秒遅れる
    ["show-thumbnail"] = false,
  },
  -- Why: ウィンドウ配置は Hammerspoon が担うので，OS 標準のタイリングとぶつけない
  ["com.apple.WindowManager"] = {
    EnableTilingByEdgeDrag = false,
    EnableTopTilingByEdgeDrag = false,
    EnableTilingOptionAccelerator = false,
  },
  ["com.apple.menuextra.clock"] = {
    ShowSeconds = true,
    ShowDayOfWeek = true,
  },
  -- Why 2 ドメイン: 内蔵トラックパッドと Bluetooth の Magic Trackpad で設定の置き場が別
  ["com.apple.AppleMultitouchTrackpad"] = {
    Clicking = true,
  },
  ["com.apple.driver.AppleBluetoothMultitouch.trackpad"] = {
    Clicking = true,
  },
}

local restarts = {
  ["com.apple.dock"] = "Dock",
  ["com.apple.finder"] = "Finder",
  ["com.apple.screencapture"] = "SystemUIServer",
  ["com.apple.WindowManager"] = "WindowManager",
  ["com.apple.menuextra.clock"] = "ControlCenter",
}

local function quote(s)
  return "'" .. tostring(s):gsub("'", [['\'']]) .. "'"
end

local function encode(value)
  local kind = type(value)
  if kind == "boolean" then
    return "-bool", value and "true" or "false", value and "1" or "0"
  elseif kind == "number" then
    local text = string.format("%g", value)
    return math.floor(value) == value and "-int" or "-float", text, text
  elseif kind == "string" then
    return "-string", value, value
  end
  error("unsupported value type: " .. kind)
end

-- Why not assert(os.execute(...)): LuaJIT の os.execute は Lua 5.1 互換で終了コードの数値を返し，
-- 失敗時の非 0 も truthy なので assert をすり抜ける
local function run(cmd)
  local status = os.execute(cmd)
  return status == 0 or status == true
end

local function current(domain, key)
  local pipe = io.popen("defaults read " .. quote(domain) .. " " .. quote(key) .. " 2>/dev/null")
  local out = pipe:read("*a"):gsub("%s+$", "")
  pipe:close()
  return out
end

local changed = {}
for domain, keys in pairs(settings) do
  for key, value in pairs(keys) do
    local flag, arg, expected = encode(value)
    -- Why not 常に書き込む: 差分のない apply でも Dock や Finder が再起動してしまう
    if current(domain, key) ~= expected then
      print(string.format("defaults: %s %s = %s", domain, key, arg))
      if not run(table.concat({ "defaults write", quote(domain), quote(key), flag, quote(arg) }, " ")) then
        error(string.format("defaults write failed: %s %s", domain, key))
      end
      changed[domain] = true
    end
  end
end

for domain in pairs(changed) do
  local process = restarts[domain]
  if process then
    run("killall " .. quote(process) .. " >/dev/null 2>&1")
  end
end
