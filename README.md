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

```lua
local Base = Object()

-- Tips:
-- You can also do like this
--
-- local Base = {}
-- Object(Base)
--
-- or
--
-- local Base = Object({})

local b = Base()

print(b:instanceOf(Base))
print(b.proto == Base)

-- Make Derived inherit from Base
local Derived = Object(Base)

-- Tips:
-- You can also do like this
--
-- local Derived = {}
-- Object(Base, Derived)

local d = Derived()

print(d:instanceOf(Derived)) -- Will print "true"
print(d.proto == Derived)    -- Will print "true"
print(d:instanceOf(Base))    -- Will print "true"
print(d.proto == Base)       -- Will print "true"
```

#### 1.2 Extend (Mixin)

Mixin help you to reuse code between objects like `C++` template.

```lua
--- @param object another object to clone its method
Object:extends = function (object)
```

### 2. Initializers

```lua
local Base = Object()

function Base:new()
  self.name = 'Base'
end
```

### 3. Operator overloading

Something like C++ and Ruby. Coders can customizes the Lua operators for operands of user-defined types.

Such like using `def +(obj)` in Ruby and `T operator+(T const& obj)` in C++.

```lua
local Base = {}

function Base:new( n )
  self.n = n
end

function Base:__add(op1, op2)
  return op1.n + op2.n
end

local b1 = Base(100)
print("b1.n =", b1.n) -- 100

local b2 = Base(200)
print("b2.n =", b2.n) -- 200

local b3 = b1 + b2
print("b3.n =", b3.n) -- 300
```

This `__add` also effects on `Derived` objects:

```lua
local Derived = Object(Base)

local d1 = Base(100)
print("d1.n =", d1.n) -- 100

local d2 = Base(200)
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
function add(lhs, rhs)
end
```

#### 3.1 Sub Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @return any Result to return
function sub(lhs, rhs)
end
```

#### 3.1 Mul Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @return any Result to return
function mul(lhs, rhs)
end
```

#### 3.1 Div Operator interface

```lua
--- @param lhs any Left number
--- @param rhs any Right number
--- @return any Result to return
function div(lhs, rhs)
end
```

#### 3.1 Concat Operator interface

Concat interface is implemented for concat some string like objects.

```lua
--- @param str1 any Left number
--- @param str2 any Right number
--- @return any Result to return
function concat(str1, str2)
end
```

### 4. Getter and Setter

Without getter and setter, you can't get private member defined in closure.

```lua
local Base = Object()
local BaseProperty = {n = 100}

function Base:getN( ... )
  return BaseProperty.n
end

function Base:setN( n )
  BaseProperty.n = n
end

local b1 = Base()
print("b1.n =", b1.n) -- Will print "b1.n = 100"
b1.n = 1024
print("b1.n =", b1.n) -- Will print "b1.n = 1024"
```

Getter and setter are bind to `get` + **camel cased** value name `N` like `getN`

### 5. Clone objects

```lua
local b1 = Base()

local b2 = b1:clone() -- Clone the object and have same prototype of Base
```

### 6. Method Caching

You can test method call performance by this sample code: \
(The sample below is disabled method caching)

```lua
local Base = Object()
function Base:test()
  return 'Base:test'
end

local Last = Base
local arr = {}

-- This gives 20 level inheritance hierachy and store to an array
-- Base <- object <- object <- object ...

for i = 1, 20 do
  local object = Object(Last)
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
Object:setMethodCache(true) -- Enable method caching

for i = 1, 20 do
  local object = Object(Last)
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

This can only cost about **100 ms** to **300 ms** to get loop done.

## License

This module is BSD-Licensed
