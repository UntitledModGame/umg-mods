local fonts = {}

local LARGE_FONT_FILE = assert(love.filesystem.newFileData("assets/fonts/Smart 9h.ttf"))
local SMALL_FONT_FILE = assert(love.filesystem.newFileData("assets/fonts/Match 7h.ttf"))


---@param fontfile love.FileData
---@param desttab table<number,love.Font?>
local function makeLoader(fontfile, desttab)
    ---@param size number?
    return function(size)
        size = size or 16
        local font = desttab[size]
        if not font then
            font = love.graphics.newFont(fontfile, size, "mono", 1)
            font:setFilter("nearest", "nearest")

            local RU_FONT = love.graphics.newFont(16)
            local CN_FONT = love.graphics.newFont(love.filesystem.newFileData("assets/fonts/CN.ttf"), size, "mono", 1)
            font:setFallbacks(CN_FONT, RU_FONT)

            desttab[size] = font
        end
        return font
    end
end

fonts.getLargeFont = makeLoader(LARGE_FONT_FILE, setmetatable({}, {__mode = "v"}))
fonts.getSmallFont = makeLoader(SMALL_FONT_FILE, setmetatable({}, {__mode = "v"}))

-- set global default font:
love.graphics.setFont(fonts.getSmallFont(16))

return fonts
