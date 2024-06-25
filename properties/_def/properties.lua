---@meta

local properties = {}


--- Defines a property
---@param property string
---@param config {base: string, default: number?, requiredComponents: table?, getModifier: function?, getMultiplier: function?, onRecalculate: function?}
function properties.defineProperty(property, config)
end



--- Computes a property
---@param ent Entity
---@param property string
---@return number
function properties.computeProperty(ent, property)
end



--- Gets the default value of a property
---@param property string
---@return number
function properties.getDefault(property)
end



--- Gets the default value of a property
---@return string[]
function properties.getAllProperties()
end


--- Checks whether a property exists or not
---@param property string
---@return boolean
function properties.isProperty(property)
end





return properties

