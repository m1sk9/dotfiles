package.path = (arg[0]:match("^(.*)/") or ".") .. "/?.lua;" .. package.path

local json = require("json")
local render = require("render")

local function quote(s)
  return "'" .. s:gsub("'", [['\'']]) .. "'"
end

-- Why not git status で dirty なども出す: 大きなリポジトリでは status が描画のたびに
-- 走って CPU を食い続ける（旧 statusline の activity 行で実際に起きた）．branch 名だけなら一瞬で済む
local function git_branch(dir)
  if not dir then
    return nil
  end
  local pipe = io.popen("git -C " .. quote(dir) .. " branch --show-current 2>/dev/null")
  local branch = pipe:read("*l")
  pipe:close()
  return branch
end

local ok, input = pcall(json.decode, io.read("*a"))
if not ok or type(input) ~= "table" then
  io.write("statusline: invalid input")
  return
end

local dir = (input.workspace and input.workspace.current_dir) or input.cwd
io.write(render.render(input, git_branch(dir)))
