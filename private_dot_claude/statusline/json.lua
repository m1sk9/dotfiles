-- Why not rxi/json.lua などを vendoring: 読むのは Claude Code が渡す JSON だけで，
-- encode もエラー位置の親切な報告も要らない．依存を増やさず自前の decode だけで足りる
local M = {}

local escapes = {
  ['"'] = '"', ["\\"] = "\\", ["/"] = "/",
  b = "\b", f = "\f", n = "\n", r = "\r", t = "\t",
}

local function utf8(code)
  if code < 0x80 then
    return string.char(code)
  elseif code < 0x800 then
    return string.char(0xC0 + math.floor(code / 0x40), 0x80 + code % 0x40)
  elseif code < 0x10000 then
    return string.char(0xE0 + math.floor(code / 0x1000), 0x80 + math.floor(code / 0x40) % 0x40, 0x80 + code % 0x40)
  end
  return string.char(
    0xF0 + math.floor(code / 0x40000),
    0x80 + math.floor(code / 0x1000) % 0x40,
    0x80 + math.floor(code / 0x40) % 0x40,
    0x80 + code % 0x40
  )
end

local decode_value

local function skip(s, i)
  return s:find("[^ \t\r\n]", i) or #s + 1
end

local function decode_string(s, i)
  local parts = {}
  local j = i + 1
  while true do
    local c = s:sub(j, j)
    if c == "" then
      error("unterminated string at " .. i)
    elseif c == '"' then
      return table.concat(parts), j + 1
    elseif c == "\\" then
      local e = s:sub(j + 1, j + 1)
      if e == "u" then
        local code = tonumber(s:sub(j + 2, j + 5), 16) or error("bad \\u escape at " .. j)
        j = j + 6
        if code >= 0xD800 and code <= 0xDBFF and s:sub(j, j + 1) == "\\u" then
          local low = tonumber(s:sub(j + 2, j + 5), 16)
          if low and low >= 0xDC00 and low <= 0xDFFF then
            code = 0x10000 + (code - 0xD800) * 0x400 + (low - 0xDC00)
            j = j + 6
          end
        end
        parts[#parts + 1] = utf8(code)
      else
        parts[#parts + 1] = escapes[e] or error("bad escape at " .. j)
        j = j + 2
      end
    else
      local stop = s:find('["\\]', j) or #s + 1
      parts[#parts + 1] = s:sub(j, stop - 1)
      j = stop
    end
  end
end

local function decode_array(s, i)
  local result = {}
  i = skip(s, i + 1)
  if s:sub(i, i) == "]" then
    return result, i + 1
  end
  local n = 0
  while true do
    local value
    value, i = decode_value(s, i)
    n = n + 1
    result[n] = value
    i = skip(s, i)
    local c = s:sub(i, i)
    if c == "]" then
      return result, i + 1
    elseif c ~= "," then
      error("expected ',' or ']' at " .. i)
    end
    i = skip(s, i + 1)
  end
end

local function decode_object(s, i)
  local result = {}
  i = skip(s, i + 1)
  if s:sub(i, i) == "}" then
    return result, i + 1
  end
  while true do
    if s:sub(i, i) ~= '"' then
      error("expected key at " .. i)
    end
    local key
    key, i = decode_string(s, i)
    i = skip(s, i)
    if s:sub(i, i) ~= ":" then
      error("expected ':' at " .. i)
    end
    result[key], i = decode_value(s, skip(s, i + 1))
    i = skip(s, i)
    local c = s:sub(i, i)
    if c == "}" then
      return result, i + 1
    elseif c ~= "," then
      error("expected ',' or '}' at " .. i)
    end
    i = skip(s, i + 1)
  end
end

local literals = { ["true"] = true, ["false"] = false }

decode_value = function(s, i)
  i = skip(s, i)
  local c = s:sub(i, i)
  if c == "{" then
    return decode_object(s, i)
  elseif c == "[" then
    return decode_array(s, i)
  elseif c == '"' then
    return decode_string(s, i)
  end
  local number = s:match("^-?%d+%.?%d*[eE]?[-+]?%d*", i)
  if number and number ~= "" and number ~= "-" then
    return tonumber(number), i + #number
  end
  for word, value in pairs(literals) do
    if s:sub(i, i + #word - 1) == word then
      return value, i + #word
    end
  end
  if s:sub(i, i + 3) == "null" then
    return nil, i + 4
  end
  error("unexpected character at " .. i)
end

function M.decode(s)
  local value, i = decode_value(s, 1)
  if skip(s, i) <= #s then
    error("trailing data at " .. i)
  end
  return value
end

return M
