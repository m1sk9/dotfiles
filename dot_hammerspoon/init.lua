hs.window.animationDuration = 0
hs.menuIcon(false)
hs.autoLaunch(true)

-- Why not local: init.lua のチャンク終了後に GC され，監視が止まる
ConfigWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()

-- Why not screencapture の target = clipboard: ファイルとして残らなくなる．
-- 保存先に書き出された画像を拾ってクリップボードにも入れ，両方を得る
local screenshotDir = hs.execute("defaults read com.apple.screencapture location"):gsub("%s+$", ""):gsub("^~", os.getenv("HOME"))
local copiedScreenshots = {}
ScreenshotWatcher = hs.pathwatcher.new(screenshotDir, function(paths)
  for _, path in ipairs(paths) do
    local name = path:match("[^/]+$")
    -- 書き出し中の一時ファイルはドット始まりの名前で作られ，完成後に rename される
    if name:match("%.png$") and not name:match("^%.") and not copiedScreenshots[path] then
      local image = hs.image.imageFromPath(path)
      if image then
        hs.pasteboard.writeObjects(image)
        copiedScreenshots[path] = true
      end
    end
  end
end):start()

local units = {
  leftHalf = { x = 0, y = 0, w = 1 / 2, h = 1 },
  rightHalf = { x = 1 / 2, y = 0, w = 1 / 2, h = 1 },
  centerHalf = { x = 1 / 4, y = 0, w = 1 / 2, h = 1 },
  maximize = { x = 0, y = 0, w = 1, h = 1 },
  firstThird = { x = 0, y = 0, w = 1 / 3, h = 1 },
  centerThird = { x = 1 / 3, y = 0, w = 1 / 3, h = 1 },
  lastThird = { x = 2 / 3, y = 0, w = 1 / 3, h = 1 },
  firstTwoThirds = { x = 0, y = 0, w = 2 / 3, h = 1 },
  centerTwoThirds = { x = 1 / 6, y = 0, w = 2 / 3, h = 1 },
  lastTwoThirds = { x = 1 / 3, y = 0, w = 2 / 3, h = 1 },
}

-- 既に左半分にあるウィンドウへ再度「左半分」を押すと，左隣のディスプレイの右半分へ送る
-- （Rectangle の subsequentExecutionMode = acrossMonitor 相当）
local across = {
  leftHalf = { toward = "toWest", landing = "rightHalf" },
  rightHalf = { toward = "toEast", landing = "leftHalf" },
}

local function isAt(win, unit, screen)
  local target = screen:fromUnitRect(unit)
  local frame = win:frame()
  -- Why not 完全一致: Ghostty などのターミナルはセル単位にサイズを丸めるため，
  -- 指定した矩形から数十 px ずれた位置で止まる
  local tolerance = 30
  return math.abs(frame.x - target.x) <= tolerance
    and math.abs(frame.y - target.y) <= tolerance
    and math.abs(frame.w - target.w) <= tolerance
    and math.abs(frame.h - target.h) <= tolerance
end

local function place(name)
  return function()
    local win = hs.window.focusedWindow()
    if not win then
      return
    end
    local screen = win:screen()
    local hop = across[name]
    if hop and isAt(win, units[name], screen) then
      local neighbor = screen[hop.toward](screen)
      if neighbor then
        win:move(units[hop.landing], neighbor, true)
        return
      end
    end
    win:move(units[name], screen, true)
  end
end

local function screensByX()
  local screens = hs.screen.allScreens()
  table.sort(screens, function(a, b)
    return a:frame().x < b:frame().x
  end)
  return screens
end

local function moveToDisplay(step)
  return function()
    local win = hs.window.focusedWindow()
    if not win then
      return
    end
    local screens = screensByX()
    local current = win:screen():id()
    for i, screen in ipairs(screens) do
      if screen:id() == current then
        win:moveToScreen(screens[(i - 1 + step) % #screens + 1], false, true)
        return
      end
    end
  end
end

local alt = { "alt" }
local altShift = { "alt", "shift" }
local cmdShift = { "cmd", "shift" }
local ctrlAlt = { "ctrl", "alt" }

hs.hotkey.bind(alt, "left", place("leftHalf"))
hs.hotkey.bind(alt, "right", place("rightHalf"))
hs.hotkey.bind(alt, "f", place("maximize"))
hs.hotkey.bind(cmdShift, "c", place("centerHalf"))

hs.hotkey.bind(ctrlAlt, "d", place("firstThird"))
hs.hotkey.bind(ctrlAlt, "f", place("centerThird"))
hs.hotkey.bind(ctrlAlt, "g", place("lastThird"))
hs.hotkey.bind(ctrlAlt, "e", place("firstTwoThirds"))
hs.hotkey.bind(ctrlAlt, "r", place("centerTwoThirds"))
hs.hotkey.bind(ctrlAlt, "t", place("lastTwoThirds"))

hs.hotkey.bind(altShift, "left", moveToDisplay(-1))
hs.hotkey.bind(altShift, "right", moveToDisplay(1))
