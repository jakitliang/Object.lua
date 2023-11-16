--- Object.lua
--- Enjoy Objective Coding!
--- Prototype based and elastic util
--- @author Jakit Liang 泊凛
--- @date 2023-10-12
--- @license MIT

local __cache = false
local DefaultObjectName = 'table'
local STRING = 'string'
local TABLE = 'table'
local FUNCTION = 'function'
local INDEX, NEW_INDEX = '__index', '__newindex'
local READ_ACCESSOR, WRITE_ACCESSOR = INDEX, NEW_INDEX
local MODE_ACCESSOR, CALL_ACCESSOR, PAIRS_ACCESSOR = '__mode', '__call', '__pairs'
local STRING_ACCESSOR, NAME_ACCESSOR = '__tostring', '__name'
local ADD_ACCESSOR, SUB_ACCESSOR, MUL_ACCESSOR, DIV_ACCESSOR = '__add', '__sub', '__mul', '__div'
local CONCAT_ACCESSOR, CONSTRUCT_ACCESSOR, NIL_ACCESSOR = '__concat', 'new', nil

local function __index(t, k, accessor)
  local proto, ret = t, nil

  if accessor then
    while proto do
      ret = rawget(proto, accessor)

      if ret ~= nil then
        return ret
      end

      proto = getmetatable(proto)
    end

    return
  end

  accessor = READ_ACCESSOR

  while proto do
    ret = rawget(proto, k)

    if ret ~= nil then
      if __cache and type(ret) == FUNCTION and not rawget(t, k) then
        rawset(t, k, ret)
      end

      return ret
    end

    ret = rawget(proto, accessor)

    if ret ~= nil then
      ret = ret(t, k)

      if ret ~= nil then
        return ret
      end
    end

    proto = getmetatable(proto)
  end
end

local function __newindex(t, k, v)
  local accessor = __index(t, nil, WRITE_ACCESSOR)

  if accessor then
    accessor(t, k, v)
    return
  end

  rawset(t, k, v)
end

local function __send(t, accessor, ...)
  local method = __index(t, nil, accessor)
  return method and method(...) or nil
end

local function __call(self, ...)
  return __send(self, CALL_ACCESSOR, self, ...)
end

local function __add(op1, op2)
  return __send(op1, ADD_ACCESSOR, op1, op2)
end

local function __sub(op1, op2)
  return __send(op1, SUB_ACCESSOR, op1, op2)
end

local function __mul(op1, op2)
  return __send(op1, MUL_ACCESSOR, op1, op2)
end

local function __div(op1, op2)
  return __send(op1, DIV_ACCESSOR, op1, op2)
end

local function __concat(op1, op2)
  return __send(op1, CONCAT_ACCESSOR, op1, op2)
end

local function __pairs(self)
  return __index(self, nil, PAIRS_ACCESSOR) or next, self, nil
end

local function __tostring(self)
  local __tostring = __index(self, nil, STRING_ACCESSOR) or DefaultObjectName

  if type(__tostring) == 'function' then
    return __tostring(self)
  end

  return string.format('%s: %p', __tostring, self)
end

local function fallback(...) error('object is a static module') end

--- @generic T1, T2
--- @param proto T1
--- @param extend T2
--- @return T1|T2
local function extends(proto, extend)
  --- @type metatable
  local metatable = {
    __index = __index,
    __newindex = __newindex,
    __call = __call,
    __add = __add,
    __sub = __sub,
    __mul = __mul,
    __div = __div,
    __concat = __concat,
    __pairs = __pairs,
    __tostring = __tostring,
    __metatable = extend or false
  }
  rawset(proto, '__metatable', metatable)
  return setmetatable(proto, metatable)
end

local function getArgs(func)
  local args = {}
  for i = 1, debug.getinfo(func).nparams, 1 do
    --- @diagnostic disable-next-line: param-type-mismatch
    table.insert(args, debug.getlocal(func, i))
  end
  return args
end

local function getAttributes(object, info)
  for k, v in pairs(object) do
    local t = type(rawget(object, k))

    if k == '__metatable' then
      goto continue
    end

    if t == 'function' then
      table.insert(info, '@field ' .. k .. ' ' .. 'fun(' .. table.concat(getArgs(v), ", ") .. ')')

    else
      table.insert(info, '@field ' .. k .. ' ' .. t)
    end

    ::continue::
  end

  return info
end

--- <b>Object.lua </b> <br/>
--- <i>Enjoy Objective Coding!</i> <br/>
--- Version: 3.0
--- @class object
local object, Object

--- @generic T
--- @param self T
--- @return T
local function checkSelf(self)
  if getmetatable(self) == Object then
    return rawget(self, '__self') or error(string.format('Illegal param %s', self))
  end

  if self == object then
    fallback()
  end

  if type(self) ~= TABLE then
    error(string.format('object must be <table> but given <%s>', type(self)))
  end

  return self
end

--- @generic T
--- @param self T
--- @return T
local function checkProto(self)
  if getmetatable(self) == Object then
    return rawget(self, '__proto') or error(string.format('Illegal param %s', self))
  end

  if type(self) ~= TABLE then
    error(string.format('object must be <table> but given <%s>', type(self)))
  end

  return self
end

--- Create new table from object
--- @generic T
--- @param self T
--- @return T
local function new(self, ...)
  self = extends({}, checkSelf(self))
  local accessor = __index(self, nil, CONSTRUCT_ACCESSOR)
  if accessor then
    accessor(self, ...)
  end

  return self
end

--- Declare object or table as class and return class table
--- @generic T1, T2
--- @param self T1
--- @param extend? T2
--- @return T1|T2|{} table Table
local function class(self, extend)
  return extends(checkSelf(self), extend)
end

--- Call method with parameters
--- @return any result
local function send(self, k, ...)
  local method = checkSelf(self)[k]
  if type(method) == 'function' then
    return method(...)
  end
end

--- Check if object have method
local function respondTo(self, k)
  return type(checkProto(self)[k]) == 'function'
end

--- Mix the methods from extend table into self
--- @generic T1, T2
--- @param self T1 The object it self
--- @param extend T2 Another object to mix
--- @return T1|T2 table Table
local function mixin(self, extend)
  self = checkSelf(self)

  for k, v in pairs(extend) do
    if string.find(k, '__') or k == 'new' or k == 'init' then
      goto continue
    end

    if not self[k] then
      rawset(self, k, rawget(extend, k))
    end

    ::continue::
  end

  return self
end

--- Clone the object
--- @generic T
--- @param self T The object it self
--- @return T table Table
local function clone(self)
  self = checkSelf(self)

  local mirror = {}

  for k, v in pairs(self) do
    rawset(mirror, k, v)
  end

  return extends(mirror, getmetatable(self))
end

--- Check whether the object is prototype of the specified one
--- @param self any The object it self
--- @param extend any The prototype of the object
--- @return boolean boolean Check result
local function is(self, extend)
  self = checkSelf(self)

  while self do
    if self == extend then
      return true
    end

    self = getmetatable(self)
  end

  return false
end

--- Set object table to weak mode
--- @generic T
--- @param self T The object it self
--- @param mode 'k'|'v'|'kv'
local function setWeak(self, mode)
  local metatable = rawget(checkSelf(self), '__metatable')
  if metatable then
    rawset(metatable, '__mode', mode)
    return true
  end
  return false
end

--- Print object or table description
--- @generic T
--- @param self T The object it self
--- @param name string
--- @return nil
local function description(self, name, extend)
  self = checkSelf(self)

  name = "@class " .. name
  if extend then
    name = name .. ' : ' .. extend
  end

  local info = {name}
  getAttributes(self, info)

  for i = 1, #info do
    print(string.format('--- %s', info[i]))
  end
end

--- Set method cache to improve performance
--- @param mode boolean If to enable the cache
local function setMethodCache(mode)
  if mode then
    __cache = true
    return
  end

  __cache = false
end

object = {
  new = new,
  class = class,
  send = send,
  respondTo = respondTo,
  mixin = mixin,
  clone = clone,
  is = is,
  setWeak = setWeak,
  description = description,
  setMethodCache = setMethodCache
}

Object = {
  --- Create new table from object
  --- @generic T
  --- @type fun(self:{proto:T}, ...):T
  new = new,
  --- Declare object or table as class and return class table
  --- @generic T1, T2
  --- @type fun(self:{proto:T1}, extend?:T2):T1|T2
  class = class,
  send = send,
  respondTo = respondTo,
  --- Mix the methods from extend table into self
  --- @generic T1, T2
  --- @type fun(self:{proto:T1}, extend:T2):T1|T2
  mixin = mixin,
  --- Clone the object
  --- @generic T
  --- @type fun(self:{proto:T}):T
  clone = clone,
  is = is,
  setWeak = setWeak,
  description = description
}

--- Cast object to class type
--- @generic T1, T2
--- @param self T1
--- @param proto T2
--- @return T2|self
function Object:cast(proto)
  if getmetatable(self) ~= Object then
    error('casting only support <object>')
    return nil
  end

  return rawset(self, '__proto', proto)
end

rawset(Object, '__index', function (t, k)
  if k == 'proto' then
    return rawget(t, '__proto')
  end

  return rawget(rawget(t, '__self'), k) or __index(rawget(t, '__proto'), k) or Object[k]
end)
rawset(Object, '__newindex', function (t, k, v)
  local accessor = __index(rawget(t, '__proto'), nil, '__newindex')
  t = rawget(t, '__self')

  if accessor then
    accessor(t, k, v)
    return
  end

  rawset(t, k, v)
end)

setmetatable(Object, {
  __newindex = fallback
})

object = (
  --- @generic self, class, T
  --- @param self self
  --- @param class class
  --- @return self|fun(proto: T):(class|T|{proto:T})
  function (self, class, call)
    return setmetatable(self, {
      __call = function (self, table)
        return call(table)
      end,
      __newindex = fallback,
      __metatable = false
    })
  end
  )(
  object, Object,
  function (proto)
    proto = checkSelf(proto)
    return extends({__self = proto, __proto = proto}, Object)
  end
)

return object
