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

```lua
local Base = Object()

-- Tips:
-- 你也可以这么写
--
-- local Base = {}
-- Object(Base)
--
-- 或者这么写
--
-- local Base = Object({})

local b = Base()

print(b:instanceOf(Base))
print(b.proto == Base)

-- Make Derived inherit from Base
local Derived = Object(Base)

-- Tips:
-- 你也可以这么写
--
-- local Derived = {}
-- Object(Base, Derived)

local d = Derived()

print(d:instanceOf(Derived)) -- print "true"
print(d.proto == Derived)    -- print "true"
print(d:instanceOf(Base))    -- print "true"
print(d.proto == Base)       -- print "true"
```

#### 1.2 扩展 (Mixin)

Mixin 帮助您在“C++”模板或“Java”接口等对象之间重用代码

```lua
local Interface = Object()

function Interface:onClick()
  print('Interface:onClick')
end

local Control = Object()
function Control:click()
  self:onClick()
end

local Window = Object(Control)
Window:extends(Interface)

local Button = Object(Control)
Button:extends(Interface)

local w = Window()
w:click()

local b = Button()
b:click()
```

### 2. 构造函数

```lua
local Base = Object()

function Base:new()
  self.name = 'Base'
end
```

### 3. 符号重载

比如 C++ 和 Ruby。 编码人员可以为用户定义类型的操作数定制 Lua 运算符。

例如，在 Ruby 中使用 `def +(obj)`，在 C++ 中使用 `T operator+(T const& obj)`。

接下来我告诉你 Object.lua 怎么用这个：

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

这个 `__add` 也可以被继承哦！比如下面的 `Derived` 对象:

```lua
local Derived = Object(Base)

local d1 = Base(100)
print("d1.n =", d1.n) -- 100

local d2 = Base(200)
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
local Base = Object()
local BaseProperty = {n = 100}

function Base:getN( ... )
  return BaseProperty.n
end

function Base:setN( n )
  BaseProperty.n = n
end

local b1 = Base()
print("b1.n =", b1.n) -- print "b1.n = 100"
b1.n = 1024
print("b1.n =", b1.n) -- print "b1.n = 1024"
```

#### 说明

> 一般情况 直接设置公开属性就完了，不要写 getter setter，一般写 getter setter 都是特殊目的的！

Getter 跟 Setter 是绑定到 `get` + **首字母大写** 的属性名称 `N` 比如 `getN`

假如属性 名称是 `n` 那就是 `getN`

* 用户写 object.value 等同于 调用了 object:getValue()
* 用户写 object.value = value 等同于调用了 object:setValue(value)

好处是，萌新不需要学习和实现 `__index` 方法了

写 getter setter 是为了 限制用户 设置某些值的时候，做一下 **判断、过滤、转换**

比如：

```lua
function Base:setN(n)
  if type(n) ~= 'number' then
    -- 拦截 不是 数字类型的属性 设置进去
    return
  end

  -- 是数值 number 类型才能设置
  self.n = n
end
```

### 5. 克隆对象

```lua
local b1 = Base()

local b2 = b1:clone() -- 克隆对象并具有相同的 Base 原型
```

### 6. 方法缓存

您可以通过以下示例代码测试方法调用性能： \
（下面的示例，没有开启方法缓存，所以比较慢）

```lua
local Base = Object()
function Base:test()
  return 'Base:test'
end

local Last = Base
local arr = {}

-- 提供了 20 级继承层次结构并存储到数组
-- Base <- object <- object <- object ...

for i = 1, 20 do
  local object = Object(Last)
  table.insert(arr, object)
  Last = object
end

-- 跑 1百万次
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
Object:setMethodCache(true) -- 启动方法缓存！

for i = 1, 20 do
  local object = Object(Last)
  table.insert(arr, object)
  Last = object
end

-- 调用
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
