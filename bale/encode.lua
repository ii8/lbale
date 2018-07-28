
local function u8(e, u)
  table.insert(e, string.char(u))
  return e
end

local function p(e, fmt, v)
  table.insert(e, string.pack(fmt, v))
  return e
end

local function u16(e, u)
  return p(e, ">I2", u)
end

local function u32(e, u)
  return p(e, ">I4", u)
end

local function u64(e, u)
  return p(e, ">I8", u)
end

local function i8(e, i)
  return p(e, ">i1", i)
end

local function i16(e, i)
  return p(e, ">i2", i)
end

local function i32(e, i)
  return p(e, ">i4", i)
end

local function i64(e, i)
  return p(e, ">i8", i)
end

local function f32(e, f)
  return p(e, ">f", f)
end

local function f64(e, f)
  return p(e, ">d", f)
end

local function uvs(v)
  if v <= 240 then
    return string.char(v)
  elseif v <= 2287 then
    return string.char((v - 240 >> 8) + 241, v - 240 & 0xff)
  elseif v <= 67823 then
    return string.char(249, v - 2288 >> 8, v - 2288 & 0xff)
  else
    local t = { }
    while v > 0 do
      table.insert(t, 1, v & 0xff)
      v = v >> 8
    end
    return string.char(247 + #t, table.unpack(t))
  end
end

local function uv(e, v)
  table.insert(e, uvs(v))
  return e
end

local function array(e, f, a)
  e:uv(#a)
  for i, v in ipairs(a) do
    f(e, v)
  end
  return e
end

local function none(e)
  error("none")
end

local function void(e)
  return e
end

local function bool(e, b)
  table.insert(e, string.char(b and 1 or 0))
  return e
end

local function maybe(e, f, v)
  if v == nil then
    table.insert(e, string.char(0))
  else
    table.insert(e, string.char(1))
    f(e, v)
  end
  return e
end

local function map(e, fk, fv, m)
  table.insert(e, "") -- placeholder for length
  local i = #e
  local len = 0
  for k, v in pairs(m) do
    len = len + 1
    fk(e, k)
    fv(e, v)
  end
  e[i] = uvs(len)
  return e
end

local function string(e, s)
  e:uv(#s)
  table.insert(e, s)
  return e
end

local function n(e, f, a)
  for i, v in ipairs(a) do
    f(e, v)
  end
  return e
end

local function write(e, s)
  table.insert(e, s)
  return e
end

local function done(e)
  return table.concat(e)
end

local t = {
  u8 = u8; u16 = u16; u32 = u32; u64 = u64;
  i8 = i8; i16 = i16; i32 = i32; i64 = i64;
  f32 = f32; f64 = f64;
  uv = uv;
  array = array;
  none = none; void = void;
  bool = bool; maybe = maybe;
  map = map;
  string = string;
  n = n; write = write;
  done = done;
}

local mt = {
  __name = "bale.encoder";
  __index = t;
}

function t.new()
  return setmetatable({ }, mt)
end

return t

