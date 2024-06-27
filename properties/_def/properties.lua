---@meta

properties = {}

---Defines a number property
---@param property string
---@param config property.NumberPropertyConfig
function properties.defineNumberProperty(property, config)
end

---Defines a boolean property
---@param property string
---@param config property.BooleanPropertyConfig
function properties.defineBooleanProperty(property, config)
end

---Computes a property
---@param ent Entity
---@param property string
---@return boolean|number
function properties.computeProperty(ent, property)
end

---Gets the default value of a property
---@param property string
---@return boolean|number
function properties.getDefault(property)
end

---@return string[]
function properties.getAllProperties()
end

---Gets property type (or `nil` if property doesn't exist)
---@param property string
---@return "boolean"|"number"|nil
function properties.getPropertyType(property)
end

return properties
