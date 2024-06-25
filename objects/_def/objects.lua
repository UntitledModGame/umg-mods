---@meta

---@class objects.Class
local Class = {}

function Class:init(...)
end

---@cast Class +fun(name:string):objects.Class

---@class objects.Set: objects.Class
local Set = {}

---Clears the Set completely.
---@return objects.Set
function Set:clear()
end

---Adds an object to the Set
---@param obj any
---@return objects.Set
function Set:add(obj)
end

---@param other objects.Set
---@return objects.Set
function Set:intersection(other)
end

---@param other objects.Set
---@return objects.Set
function Set:union(other)
end

---@param func fun(item:any):boolean
---@return objects.Set
function Set:filter(func)
end

---Removes an object from the Set.
---If the object isn't in the Set, returns nil.
---@param obj any
---@return objects.Set?
function Set:remove(obj)
end

---@return integer
function Set:length()
end
Set.size = Set.length

---returns true if the Set contains `obj`, false otherwise.
---@param obj any
---@return boolean
function Set:has(obj)
end
Set.contains = Set.has -- alias

---@cast Set +fun(initial:any[]):objects.Set

---@class objects.Array: objects.Class
local Array = {}


---Adds item to array
---@param x any
function Array:add(x)
end

---Clears array
function Array:clear()
end

---reverses the array in-place
---@return objects.Array
function Array:reverse()
end


---Returns the size of the array
function Array:size()
end
Array.length = Array.size

---Removes item from array at index
---(if index is nil, pops from the end of array.)
---@param i integer?
---@return any
function Array:remove(i)
end
Array.pop = Array.remove


---Pops item from array by swapping it with the last item
---this operation is O(1)
---
---**WARNING**: This operation DOES NOT preserve array order!!!
---@param i integer
function Array:quickRemove(i)
end
Array.quickPop = Array.quickRemove

---@param obj any
---@return integer?
function Array:find(obj)
end

---@return objects.Array
function Array:clone()
end

---@param func fun(item:any):boolean
---@return objects.Array
function Array:filter(func)
end

---@param func fun(item:any):any
---@return objects.Array
function Array:map(func)
end

---@cast Array +fun(initial:any[]?):objects.Array

---@class objects.Heap: objects.Class
local Heap = {}

---@param newValue any
function Heap:insert(newValue)
end

---@return any?
function Heap:pop()
end

---@return any?
function Heap:peek()
end

---@return any[]
function Heap:toTable()
end

function Heap:clear()
end

---@return integer
function Heap:size()
end

---@return objects.Heap
function Heap:clone()
end

---@param oldTable any[]
---@param comparator? fun(a:any,b:any):boolean
---@return objects.Heap
function Heap.heapify(oldTable, comparator)
end

---@cast Heap +fun(comparator?:fun(a:any,b:any):boolean):objects.Heap

---@class objects.Color
---@field public r number red
---@field public g number green
---@field public b number blue
---@field public a number alpha
---@field public red number
---@field public green number
---@field public blue number
---@field public alpha number
---@field public hex string
---@field public h number hue
---@field public hue number
---@field public s number saturation
---@field public saturation number
---@field public l number lightness
---@field public lightness number
---@field public ss number ssaturation
---@field public ssaturation number
---@field public v number value
---@field public value number
---@field public BLACK objects.Color
---@field public WHITE objects.Color
---@field public RED objects.Color
---@field public GREEN objects.Color
---@field public BLUE objects.Color
---@field public YELLOW objects.Color
---@field public GRAY objects.Color
---@field public CYAN objects.Color
---@field public MAGENTA objects.Color
---@field public AQUA objects.Color
---@field public BROWN objects.Color
---@field public PINK objects.Color
---@field public CORAL objects.Color
---@field public CRIMSON objects.Color
---@field public DARK_BLUE objects.Color
---@field public DARK_CYAN objects.Color
---@field public DARK_GRAY objects.Color
---@field public DARK_GREEN objects.Color
---@field public DARK_RED objects.Color
---@field public GOLD objects.Color
---@field public IVORY objects.Color
---@field public LIME objects.Color
---@field public PURPLE objects.Color
---@operator add(number|objects.Color):objects.Color
---@operator sub(number|objects.Color):objects.Color
---@operator mul(number|objects.Color):objects.Color
---@operator div(number|objects.Color):objects.Color
---@operator unm:objects.Color
---@operator pow(number):objects.Color
local Color = {}

---@param other number|objects.Color
---@return objects.Color
function Color:add(other)
end

---@param other number|objects.Color
---@return objects.Color
function Color:subtract(other)
end

---@param other number|objects.Color
---@return objects.Color
function Color:multiply(other)
end

---@param other number|objects.Color
---@return objects.Color
function Color:divide(other)
end

---@return objects.Color
function Color:invert()
end

---@param deg number
---@return objects.Color
function Color:shiftHue(deg)
end

---@param h number
---@param s number
---@param v number
---@return objects.Color
function Color:setHSV(h, s, v)
end

---@return number,number,number
function Color:getHSV()
end

---@param h number
---@param s number
---@param l number
---@return objects.Color
function Color:setHSL(h, s, l)
end

---@return number,number,number
function Color:getHSL()
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return objects.Color
function Color:setRGBA(r, g, b, a)
end

---@return number,number,number,number
function Color:getRGBA()
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return objects.Color
function Color:setByteRGBA(r, g, b, a)
end

---@return integer,integer,integer,integer
function Color:getByteRGBA()
end

---@return objects.Color
function Color:clone()
end

---@param from objects.Color
---@param to objects.Color
---@param progress number
---@return objects.Color
function Color.lerp(from, to, progress)
end

---@param a objects.Color
---@param b objects.Color
---@return number
function Color.distance(a, b)
end

---@param h number
---@param s number
---@param v number
---@return number,number,number
function Color.HSVtoRGB(h, s, v)
end

---@param r number
---@param g number
---@param b number
---@return number,number,number
function Color.RGBtoHSV(r, g, b)
end

---@param h number
---@param s number
---@param l number
---@return number,number,number
function Color.HSLtoRGB(h, s, l)
end

---@param r number
---@param g number
---@param b number
---@return number,number,number
function Color.RGBtoHSL(r, g, b)
end

---@param hex integer|string
function Color.HEXtoRGBA(hex)
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return string
function Color.RGBAtoHEX(r, g, b, a)
end

---@param hex string
---@return boolean
function Color.validateHEX(hex)
end

---@cast Color +fun(r:number,g:number,b:number,a:number):objects.Color
---@cast Color +fun(hex:integer|string):objects.Color
---@cast Color +fun(color:number[]):objects.Color

---@class objects.Grid: objects.Class
local Grid = {}

---@param x integer
---@param y integer
---@param val any
function Grid:set(x,y, val)
end

---@param x integer
---@param y integer
---@return any
function Grid:get(x,y)
end

---converts (x,y) coordinates --> index
---
---**BIG WARNING!!! indexes are ONE-INDEXED!!**
---@param x integer
---@param y integer
---@return integer
function Grid:coordsToIndex(x, y)
end

---@param x integer
---@param y integer
---@return boolean
function Grid:contains(x, y)
end

---converts index  --->  (x,y) coordinates.
---
---**BIG WARNING!!! (x,y) coords are ZERO-INDEXED!!**
---@param index integer
---@return integer,integer
function Grid:indexToCoords(index)
end

---@param func fun(value:any,x:integer,y:integer)
function Grid:foreach(func)
end

---x and y position are both inclusive
---@param x1 integer
---@param x2 integer
---@param y1 integer
---@param y2 integer
---@param func fun(value:any,x:integer,y:integer)
function Grid:foreachInArea(x1,x2, y1,y2, func)
end

---@cast Grid +fun(width:integer,height:integer):objects.Grid

objects = {}

objects.Class = Class
objects.Set = Set
objects.Array = Array
objects.Heap = Heap
objects.Color = Color
objects.Grid = Grid

---@generic T
---@param values T
---@return T
function objects.Enum(values)
end

-- An empty table. DO NOT MODIFY!!!
-- (Used as default arguments and such)
objects.EMPTY = {}

return objects
