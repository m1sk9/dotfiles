-- luajit private_dot_claude/statusline/.tests/run.lua
local root = arg[0]:match("^(.*)/%.tests/") or "."
package.path = root .. "/?.lua;" .. package.path

local json = require("json")
local render = require("render")

local failures = 0
local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    print("ok   " .. name)
  else
    failures = failures + 1
    print("FAIL " .. name .. "\n     " .. tostring(err))
  end
end

local function eq(actual, expected)
  if actual ~= expected then
    error(string.format("expected %q, got %q", tostring(expected), tostring(actual)), 2)
  end
end

local function plain(s)
  return (s:gsub("\27%[[%d;]*m", ""))
end

test("json: nested objects, arrays and literals", function()
  local v = json.decode('{"a":{"b":[1,2.5,-3e2]},"t":true,"f":false,"n":null}')
  eq(v.a.b[1], 1)
  eq(v.a.b[2], 2.5)
  eq(v.a.b[3], -300)
  eq(v.t, true)
  eq(v.f, false)
  eq(v.n, nil)
end)

test("json: string escapes and unicode, including surrogate pairs", function()
  local v = json.decode('"a\\"b\\\\c\\n\\u3042\\ud83d\\ude00"')
  eq(v, 'a"b\\c\nあ😀')
end)

test("json: raw multibyte text passes through", function()
  eq(json.decode('"作業 dir"'), "作業 dir")
end)

test("json: whitespace around tokens", function()
  local v = json.decode(' {\n "k" : [ 1 , 2 ] } \n')
  eq(#v.k, 2)
end)

test("json: malformed input is an error", function()
  eq(pcall(json.decode, '{"a":'), false)
  eq(pcall(json.decode, '{"a":1} x'), false)
end)

test("duration: seconds, minutes, then hours with zero-padded minutes", function()
  eq(render.duration(42000), "42s")
  eq(render.duration(5 * 60000 + 30000), "5m")
  eq(render.duration(3600000 + 5 * 60000), "1h05m")
end)

local full = {
  model = { display_name = "Opus 5.5 (1M context)" },
  effort = { level = "high" },
  workspace = { current_dir = "/Users/me/.local/share/chezmoi" },
  context_window = { used_percentage = 41.6 },
  cost = { total_duration_ms = 4980000, total_cost_usd = 1.234 },
}

test("render: all segments in order, without the context-size suffix", function()
  eq(plain(render.render(full, "main")), "Opus 5.5 · high · chezmoi ⎇ main · ctx 42% · 1h23m · $1.23")
end)

test("render: missing fields drop their segments", function()
  eq(plain(render.render({ model = { display_name = "Haiku" }, cwd = "/tmp/x/" }, nil)), "Haiku · x")
end)

test("render: no branch outside a git repository", function()
  eq(plain(render.render({ workspace = { current_dir = "/tmp" } }, "")), "tmp")
end)

test("render: context colour turns warn at 60% and crit at 80%", function()
  local function ctx(pct)
    return render.render({ context_window = { used_percentage = pct } })
  end
  eq(ctx(59):find("230;234;234", 1, true) ~= nil, true)
  eq(ctx(60):find("253;164;127", 1, true) ~= nil, true)
  eq(ctx(80):find("232;92;81", 1, true) ~= nil, true)
end)

if failures > 0 then
  os.exit(1)
end
