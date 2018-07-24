
local function str(s)
  return {
    pos = 1,
    s = s,
    read = function(self, n)
      local pos = self.pos
      if pos > #self.s then
        return nil
      end
      self.pos = pos + n
      return string.sub(self.s, pos, pos + (n - 1))
    end
  }
end

local function u8(s)
  local b = s:read(1)
  if b == nil then
    return nil, "unexpected end of input"
  end
  return string.byte(b)
end

local function rd(s, n, fmt)
  local data = s:read(n)
  if data == nil or #data < n then
    return nil, "unexpected end of input"
  end
  local v = string.unpack(fmt, data)
  return v
end

local function u16(s)
  return rd(s, 2, ">I2")
end

local function u32(s)
  return rd(s, 4, ">I4")
end

local function u64(s)
  return rd(s, 8, ">I8")
end

local function i8(s)
  return rd(s, 1, ">i1")
end

local function i16(s)
  return rd(s, 2, ">i2")
end

local function i32(s)
  return rd(s, 4, ">i4")
end

local function i64(s)
  return rd(s, 8, ">i8")
end

local function f32(s)
  return rd(s, 4, ">f")
end

local function f64(s)
  return rd(s, 8, ">d")
end

local function uv(s)
  local a0, e = u8(s)
  if a0 == nil then
    return nil, e
  end

  if a0 <= 240 then
    return a0
  elseif a0 <= 248 then
    local a1, e = u8(s)
    if a1 == nil then
      return nil, e
    end
    return 240 + 256 * (a0 - 241) + a1
  elseif a0 == 249 then
    local a1, e = u8(s)
    if a1 == nil then
      return nil, e
    end
    local a2, e = u8(s)
    if a2 == nil then
      return nil, e
    end
    return 2288 + 256 * a1 + a2
  else
    local r = 0
    for i = 1, a0 - 247 do
      local an, e = u8(s)
      if an == nil then
        return nil, e
      end
      r = (r << 8) | an
    end
    return r
  end
end

local function tuple(...)
  local a = table.pack(...)
  return function(s)
    local tup = { }
    for i = 1, a.n, 2 do
      local k, f = a[i], a[i + 1]
      local v, e = f(s)
      if v == nil then
        return nil, e
      end
      tup[k] = v
    end
    return tup
  end
end

local function union(...)
  local a = {...}
  return function(s)
    local i, e = uv(s)
    if i == nil then
      return nil, e
    end
    local f = a[i + 1]
    if f then
      return f(s)
    else
      return nil, "union index out of bounds"
    end
  end
end

local function array(f)
  return function(s)
    local n, e = uv(s)
    if n == nil then
      return nil, e
    end

    local arr = { }
    for i = 1, n do
      local v, e = f(s)
      if v == nil then
        return nil, e
      end
      arr[i] = v
    end

    return arr
  end
end

local function none(s)
  return nil, "encountered none"
end

local function void(v)
  return function(s)
    return v
  end
end

local function bool(s)
  local v, e = u8(s)
  if v == nil then
    return nil, e
  elseif v == 0 then
    return false
  elseif v == 1 then
    return true
  else
    return nil, "invalid boolean"
  end
end

local function maybe(f, default)
  return function(s)
    local v, e = u8(s)
    if v == nil then
      return nil, e
    elseif v == 0 then
      return default
    elseif v == 1 then
      return f(s)
    else
      return nil, "invalid maybe"
    end
  end
end

local function string(s)
  local len, e = uv(s)
  if len == nil then
    return nil, e
  end

  local str = s:read(len)
  if str == nil or #str ~= len then
    return nil, "unexpected end of input"
  end
  return str
end

local function map(fk, fv)
  return function(s)
    local len, e = uv(s)
    if len == nil then
      return nil, e
    end
    local t = { }
    for i = 1, len do
      local k, e1 = fk(s)
      local v, e2 = fv(s)
      if k == nil or v == nil then
        return nil, e1 or e2
      end
      t[k] = v
    end
    return t
  end
end

local function n(n, f)
  return function(s)
    local t = { }
    for i = 1, n do
      local v, e = f(s)
      if v == nil then
        return nil, e
      end
      t[i] = v
    end
    return t
  end
end

local function read(n)
  return function(s)
    local data = s:read(n)
    if data == nil or #data < n then
      return nil, "unexpected end of input"
    end
    return data
  end
end

local function done(f)
  return function(s)
    local v, e = f(s)
    if v == nil then
      return nil, e
    elseif s:read(0) == nil then
      return v, e
    else
      return nil, "trailing input"
    end
  end
end

return {
  str = str;

  u8 = u8; u16 = u16; u32 = u32; u64 = u64;
  i8 = i8; i16 = i16; i32 = i32; i64 = i64;
  f32 = f32; f64 = f64;
  uv = uv;

  tuple = tuple;
  union = union;
  array = array;

  none = none;
  void = void;
  bool = bool;
  maybe = maybe;
  map = map;
  string = string;
  n = n;
  read = read;
  done = done;
}
