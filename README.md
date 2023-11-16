# Object.lua

> Enjoy Objective Coding!

`Object.lua` give you the simplest way to OO coding.

It is compactest memory usage and super high performance with method caching.

## Introduction

As you see, lua doesn't have an Object-oriented system.

But sometimes, we want our code to be Rich typed. A module which could help us easily identify which `table` was `new` by which `table`. So that we need a type util or helper.

`Object.lua` give `Prototype Based` desgin for you to write better and comfortable.

**Also keep high performance.**

## History

Because of traditional OOP is not suitable for `Lua` language.

### Previous Version

Although previous version is [Type.lua](https://github.com/jakitliang/Type.lua).

`Type.lua` is using `Closure Approach` way to implement.

`Closure Approach` is fast, but have the **risk of stack overflow**.

Although **recursive tail call optimization** could do some effort to optimize,

but hard to code every function in tail call factorial.

### About OOP

There is much OO modules in `Lua` community.

If using the way like `Java` and `Ruby` to OOP may have significant `Performance Lossing` in `Lua`.

Because `Java` and `Ruby` have their mechanism to improve doing method sending.

But `Lua` only have a tiny `__index` way to do method tracing.

**So the best practice for Lua do `OOP` is the `Prototype Based` design.**

## Using `Object.lua`

The way using `Object.lua` is below.

### 1. Create object and make prototype inheritance

#### 1.1 Basic usage

Create `Base` object and `Derived` object.

Set `Derived` object's prototype connect to `Base`

Then let's check `b` is a `Base`.

And check `d` is a `Derived` and also has ancestor `Base`.

**Practice 1.**

```lua
local object = require('object')
local Base = {}
Base = object(Derived):class()

local b = object(Base):new()

print(object(b):is(Base))  -- Will print "true"

-- Make Derived inherit from Base
local Derived = {}
Derived = object(Derived):class(Base)

local d = object(Derived):new()

print(object(d):is(Derived)) -- Will print "true"
print(object(d):is(Base))    -- Will print "true"
```

**Practice 2.**

```lua
local object = require('object')
local Base = object({}):class()

local b = object(Base):new()

print(object(b):is(Base))  -- Will print "true"

-- Make Derived inherit from Base
local Derived = object({}):class(Base)

local d = object(Derived):new()

print(object(d):is(Derived)) -- Will print "true"
print(object(d):is(Base))    -- Will print "true"
```

**Practice 3.**

```lua
local object = require('object')
local new, class, is = object.new, object.class, object.is

local Base = class({})

local b = new(Base)

print(is(b, Base))  -- Will print "true"

-- Make Derived inherit from Base
local Derived = class({}, Base)

local d = new(Derived)

print(is(d, Derived)) -- Will print "true"
print(is(d, Base))    -- Will print "true"
```

#### 1.2 Mixin

Mixin help you to reuse code between objects like `C++` template or `Java` interface.

```lua
local Interface = {}

function Interface:onClick()
  print('Interface:onClick')
end

local Control = {}
function Control:click()
  self:onClick()
end

local Window = object({}):class(Control) -- Inherit from Control
object(Window):mixin(Interface) -- Mixin interface

local Button = object({}):class(Control)
object(Button):mixin(Interface) -- Mixin interface

local w = Window()
w:click()

local b = Button()
b:click()
```

#### 1.3 Cast

Cast can help you work without `inheritance`.

```lua
local Control = {}
function Control:click()
  self:onClick()
end

local Window = object({}):class() -- No inheritance
function Window:onClick()
  print('Window:onClick')
end

local Button = object({}):class() -- No inheritance
function Button:onClick()
  print('Button:onClick')
end

object(Window):cast(Control):click() -- Print Window:onClick
object(Button):cast(Control):click() -- Print Button:onClick

local components = {Window, Button}

for i=1,#components do
  object(components[i]):cast(Control):click() -- Print Window:onClick and Button:onClick
end
```

#### 1.4 Check respond (Reflection)

Check if an object have the specified method

```lua
local Base = {attribute = 123}

function Base.method() end

print(object(Base):respondTo('method')) -- True
print(object(Base):respondTo('attribute')) -- False, attribute is not a function
print(object(Base):respondTo('empty')) -- False, function `empty` doesn't exists
```

#### 1.5 Reflection call

Check if an object have the specified method

```lua
local Base = {attribute = 123}

function Base.staticMethod()
  print('Base.staticMethod')
end

function Base:method()
  print('Base:method')
end

if object(Base):respondTo('staticMethod') then
  object(Base):send('staticMethod')
end

if object(Base):respondTo('method') then
  object(Base):send('method', Base) -- Member function should pass `self` into param
end
```

#### 1.5 Weak tables

> Be careful to use this feature.

Weak tables can automatically GC the member.

```lua
local Base = {attribute = 123}

object(Base):setWeak('kv')

do
  for i=1,10 do
    local v = {x = i}
    Base[v] = v
  end
end

print('Memory usage', collectgarbage('count'), 'Bytes')

collectgarbage('collect') -- GC

print('Memory usage', collectgarbage('count'), 'Bytes')
```

### 2. Initializers

```lua
local Base = object({}):class()

function Base:init()
  self.name = 'Base'
end

local b = object(Base):new()

print(b.name) -- Print `Base`
```

### 3. Operator overloading

Something like C++ and Ruby. Coders can customizes the Lua operators for operands of user-defined types.

Such like using `def +(obj)` in Ruby and `T operator+(T const& obj)` in C++.

```lua
local Base = object({}):class()

function Base:new( n )
  self.n = n
end

function Base:__add(op1, op2)
  return op1.n + op2.n
end

local b1 = object(Base):new(100)
print("b1.n =", b1.n) -- 100

local b2 = object(Base):new(200)
print("b2.n =", b2.n) -- 200

local b3 = b1 + b2
print("b3.n =", b3.n) -- 300
```

This `__add` also effects on `Derived` objects:

```lua
local Derived = object({}):class(Base)

local d1 = object(Derived):new(100)
print("d1.n =", d1.n) -- 100

local d2 = object(Derived):new(200)
print("d2.n =", d2.n) -- 200

local d3 = d1 + d2
print("d3.n =", d3.n) -- 300
```

Now `Object.lua` can support 5 Operators to be overloaded:

* `add` Operator +
* `sub` Operator -
* `mul` Operator *
* `div` Operator /
* `concat` Operator ..

#### 3.1 Add Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @return any Result to return
function __add(lhs, rhs)
end
```

#### 3.1 Sub Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @return any Result to return
function __sub(lhs, rhs)
end
```

#### 3.1 Mul Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @return any Result to return
function __mul(lhs, rhs)
end
```

#### 3.1 Div Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @return any Result to return
function __div(lhs, rhs)
end
```

#### 3.1 Concat Operator interface

Concat interface is implemented for concat some string like objects.

```lua
--- @param str1 any Left number
--- @param str2 any Right number
--- @return any Result to return
function __concat(str1, str2)
end
```

### 4. Getter and Setter

Without getter and setter, you can't get private member defined in closure.

```lua
local Base = object({}):class()

local function getN(self)
  return self.__n
end

local function setN(self, n)
  self.__n = n
end

function Base:__index( t, k )
  if k == 'n' then
    return getN(t)
  end
end

function Base:__newindex( t, k, v )
  if k == 'n' then
    setN(t, v)
  end
end

local b1 = object(Base):new()
print("b1.n =", b1.n) -- Will print "b1.n = 100"
b1.n = 1024
print("b1.n =", b1.n) -- Will print "b1.n = 1024"
```

Getter and setter are bind to `get` + **camel cased** value name `N` like `getN`

### 5. Clone objects

```lua
local b1 = object(Base):new()
b1.value = 123

local b2 = object(b1):clone() -- Clone the object and have same prototype of Base
```

### 6. Method Caching

You can test method call performance by this sample code: \
(The sample below is disabled method caching)

```lua
local Base = object({}):class()
function Base:test()
  return 'Base:test'
end

local Last = Base
local arr = {}

-- This gives 20 level inheritance hierachy and store to an array
-- Base <- object <- object <- object ...

for i = 1, 20 do
  local object = object({}):class(Last)
  table.insert(arr, object)
  Last = object
end

-- Do call
-- arr[1] -> Base:test()
-- arr[2] -> object:test() -> Base:test()
-- ...
for k = 1, 1000000 do
  for j = 1, 20 do
    local value = arr[j]
    local ret = value:test()
  end
end
```

Without caching, you may need **5 to 15 seconds** to have done.

This equal to `__index = table` which is the **general** `Lua` method finding performance.

Now lets enable the method caching feature:

```lua
-- ... codes before

-- Add this line
object.setMethodCache(true) -- Enable method caching

-- Do call
-- arr[1] -> Base:test()
-- arr[2] -> object:test() -> Base:test()
-- ...
for k = 1, 1000000 do
  for j = 1, 20 do
    local value = arr[j]
    local ret = value:test()
  end
end
```

This can only cost about **100 ms** to **300 ms** to get loop done.

## License

This module is BSD-Licensed
