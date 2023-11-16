# Object.lua

> 享受极速无损耗的对象化编码!

`Object.lua` 为您提供最简单的 OO 编码方式。

它具有世界上最紧凑的内存使用和超高性能的方法缓存。

## 介绍

如你所见，lua 没有面向对象的系统。

但有时，我们希望我们的代码是丰富类型的。 我们需要一个可以帮助我们轻松识别某个 `table` 是哪个 `table` 是 `new` 出来的。 

所以我们需要一个类型系统。

`Object.lua` 给你带来的 `面向原型` 是符合 **Lua 工学**，最符合 `Lua`，书写更好的代码量身定制设计。

**同时，已经经过一系列 Lua 虚拟机研究，得出 Object.lua 目前是最高性能的对象式编写代码办法。**

## 历史

### 之前版本

`Object.lua` 的前身是 [Type.lua](https://github.com/jakitliang/Type.lua).

`Type.lua` 使用 `Closure Approach` 来实现.

`Closure Approach` 是很快，**但堆栈溢出咋办**？

虽然通过 **尾递归** 能优化，但总归是有限的，不是所有代码都归纳于能够做 **尾递归** 优化的范畴。

让用户编写让编译器能够优化的代码，每个函数都这么做，那是在 **为难用户**。

### 关于面向对象学说

Lua 社区中有很多 OO 模块。

如果使用像“Java”和“Ruby”这样的方式进行OOP，在“Lua”中可能会有明显的“性能损失”。

因为“Java”和“Ruby”有自己的机制来改进方法发送。

但是“Lua”只有一个很小的 `__index` 方法来进行方法跟踪。

**所以 Lua 做“OOP”的最佳实践是“基于原型”设计**

## 教程

告诉你怎么用了啦

### 1. 创建对象并进行原型链继承

#### 1.1 基本用法

将“Derived”对象的原型设置为连接到“Base”

然后我们检查一下“b”是一个“Base”。

并检查“d”是“Derived”并且还有祖先“Base”。

**练习 1.**

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

**练习 2.**

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

**练习 3.**

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

#### 1.2 混入 Mixin

Mixin 帮助您在“C++”模板或“Java”接口等对象之间重用代码，非继承

```lua
local Interface = {}

function Interface:onClick()
  print('Interface:onClick')
end

local Control = {}
function Control:click()
  self:onClick()
end

local Window = object({}):class(Control) -- 继承 Control
object(Window):mixin(Interface) -- 混入接口 Interface

local Button = object({}):class(Control)
object(Button):mixin(Interface) -- 混入接口 Interface

local w = Window()
w:click()

local b = Button()
b:click()
```

#### 1.3 类型转换

有了类型转换，有时候就不需要写继承了呢

```lua
local Control = {}
function Control:click()
  self:onClick()
end

local Window = object({}):class() -- 没有继承关系
function Window:onClick()
  print('Window:onClick')
end

local Button = object({}):class() -- 没有继承关系
function Button:onClick()
  print('Button:onClick')
end

object(Window):cast(Control):click() -- Print Window:onClick
object(Button):cast(Control):click() -- Print Button:onClick

-- 把插件放进组件堆里，一起批量点击

local components = {Window, Button}

for i=1,#components do
  object(components[i]):cast(Control):click() -- Print Window:onClick and Button:onClick
end
```

#### 1.4 自省 (反射)

确认一个对象是否具有某个函数

```lua
local Base = {attribute = 123}

function Base.method() end

print(object(Base):respondTo('method')) -- True
print(object(Base):respondTo('attribute')) -- False, attribute 不是个函数方法啦，只是个属性变量
print(object(Base):respondTo('empty')) -- False, 没找到 `empty` 函数方法
```

#### 1.5 反射调用

确认一个对象是否具有某个方法并调用它

面向对象（物件导向）的理论概念，就是“向对象发送方法”

```lua
local Base = {attribute = 123}

function Base.staticMethod() -- 静态函数
  print('Base.staticMethod')
end

function Base:method() -- 成员方法
  print('Base:method')
end

if object(Base):respondTo('staticMethod') then
  object(Base):send('staticMethod')
end

if object(Base):respondTo('method') then
  object(Base):send('method', Base) -- 成员函数需要带个 `self`，这里 Base 就是 self
end
```

#### 1.5 弱表

> 小心使用这个特性.

弱表就是会自动回收成员了啦，让你体验一边用这个对象，一边它内部的成员会随 GC 自动消失，慎用！

主要是某种很独特的场景可能用得到，一般用不到。

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

### 2. 构造函数

```lua
local Base = object({}):class()

function Base:init()
  self.name = 'Base'
end

local b = object(Base):new()

print(b.name) -- Print `Base`
```

### 3. 符号重载

比如 C++ 和 Ruby。 编码人员可以为用户定义类型的操作数定制 Lua 运算符。

例如，在 Ruby 中使用 `def +(obj)`，在 C++ 中使用 `T operator+(T const& obj)`。

接下来我告诉你 Object.lua 怎么用这个：

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

这个 `__add` 也可以被继承哦！比如下面的 `Derived` 对象:

```lua
local Derived = object({}):class(Base)

local d1 = object(Derived):new(100)
print("d1.n =", d1.n) -- 100

local d2 = object(Derived):new(200)
print("d2.n =", d2.n) -- 200

local d3 = d1 + d2
print("d3.n =", d3.n) -- 300
```

现在 `Object.lua` 支持五种运算符重载:

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

Concat 接口是为了连接一些类似字符串的对象而实现的。

```lua
--- @param str1 any Left number
--- @param str2 any Right number
--- @return any Result to return
function concat(str1, str2)
end
```

### 4. Getter 和 Setter

如果没有 getter 和 setter，就无法在闭包中定义私有成员。

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

### 5. 克隆对象

```lua
local b1 = object(Base):new()
b1.value = 123

local b2 = object(b1):clone() -- Clone the object and have same prototype of Base
```

### 6. 方法缓存

您可以通过以下示例代码测试方法调用性能： \
（下面的示例，没有开启方法缓存，所以比较慢）

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

没缓存的话, 要跑 **5 到 15 秒**.

由于 `Object.lua` 做了极限调整，性能等价于 `__index = table` （就是 Lua 手册上的）通用面向对象的设计.

P.S. 其它 OO 库还不一定能达到 这个水平呢。

现在让我们启用方法缓存功能:

```lua
-- ... 前面的代码

-- 加一行在这里
object.setMethodCache(true) -- 启动方法缓存！

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

这时候只要 **100 毫秒** to **300 毫秒** 跑完了！

## License

This module is BSD-Licensed

版权归 jakitliang<https://gitee.com/jekit> 所有

版权必究！请勿抄袭！
