
local function u8(u)
  return string.char(u)
end

local function u16(u)
  return string.pack(">I2", u)
end

local function u32(u)
  return string.pack(">I4", u)
end

local function u64(u)
  return string.pack(">I8", u)
end

local function i8(i)
  return string.pack(">i1", i)
end

local function i16(i)
  return string.pack(">i2", i)
end

local function i32(i)
  return string.pack(">i4", i)
end

local function i64(i)
  return string.pack(">i8", i)
end

local function f32(f)
  return string.pack(">f", f)
end

local function f64(f)
  return string.pack(">d", f)
end

local function uv(v)
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

local function none()
  error("none")
end

local function void()
  return ""
end

local function bool(b)
  return string.char(b and 1 or 0)
end

return {
  u8 = u8; u16 = u16; u32 = u32; u64 = u64;
  i8 = i8; i16 = i16; i32 = i32; i64 = i64;
  f32 = f32; f64 = f64;
  uv = uv;
  none = none; void = void; bool = bool;
}

