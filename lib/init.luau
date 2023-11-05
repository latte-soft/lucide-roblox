-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

export type Asset = {
    Id: number, -- 123456789
    Url: string, -- "rbxassetid://123456789"
    ImageRectSize: Vector2, -- Vector2.new(48, 48)
    ImageRectOffset: Vector2, -- Vector2.new(648, 266)
}

local Icons = require(script.Icons)

local ContentProvider = game:GetService("ContentProvider")

local Type = typeof or type
local function CheckArgTypes(funcName: string, inputArgs: {any}, typeEntries: {[number]: {string}})
    for ArgIndex, TypeEntryArray in typeEntries do
        local ArgName = TypeEntryArray[1]
        local ExpectedType = TypeEntryArray[2]
        
        local InputArg = inputArgs[ArgIndex]
        local InputArgType = Type(InputArg)

        if InputArgType ~= ExpectedType then
            error(funcName .. ": Argument " .. ArgIndex .. " (" .. ArgName .. "): expected type `" .. ExpectedType .. "`, got `" .. InputArgType .. "`", 3)
        end
    end
end

local function TrimIconIdentifier(inputIconIdentifier: string): string
    return string.match(string.lower(inputIconIdentifier), "^%s*(.*)%s*$") :: string
end

local Lucide = {
    PackageVersion = "0.1.0", -- The version of this `lucide-roblox` package
    LucideVersion = "0.292.0", -- The version of the Lucide icon set itself the package ver noted above is on
}

-- Add all icon names to an array
do
    local IconNames: {string} = {}
    local FirstIconIndex = next(Icons) or {} -- If it's actually `{}`, we're in trouble..

    for IconName in FirstIconIndex do
        table.insert(IconNames, IconName)
    end

    Lucide.IconNames = IconNames
end

--[[
    This function attempts to retrieve and wrap an asset object from a specified
    icon name, optional target size most applicable/closest to what's supported, and
    optionally preload the said asset's `rbxassetid` URI, which will yield a return
    until Roblox has preloaded the actual asset

    Example:
    ```lua
    local Asset = Lucide.GetAsset("server", 48)
    assert(Asset, 'Failed to fetch asset!')

    print(Asset.Id) -- 15269177520
    print(Asset.Url) -- "rbxassetid://15269177520"
    print(Asset.ImageRectSize) -- Vector2.new(48, 48)
    print(Asset.ImageRectOffset) -- Vector2.new(0, 771)
    ```
]]
function Lucide.GetAsset(iconName: string, inputSize: number?, preload: boolean?): Asset?
    local InputSize = if inputSize == nil then 256 else inputSize
    local Preload = if preload == nil then false else preload

    CheckArgTypes("Lucide.GetAsset", {iconName, InputSize, Preload}, {
        [1] = {"iconName", "string"},
        [2] = {"inputSize", "number"},
        [3] = {"preload", "boolean"},
    })

    local IconName = TrimIconIdentifier(iconName)

    -- If reading directly from a UI obj w/ a negative size..?
    if InputSize < 0 then
        InputSize = -InputSize
    end

    local RealSizeIndex = if InputSize <= 48 then "48px" else "256px"
    local IconIndexDict = Icons[RealSizeIndex]

    if not IconIndexDict then
        error("Lucide.GetAsset: Internal error: Failed to find icon index for specified size")
    end

    local RawAsset = IconIndexDict[IconName]
    if not RawAsset then
        return
    end

    local Id = RawAsset[1]
    local RawImageRectSize = RawAsset[2]
    local RawImageRectOffset = RawAsset[3]

    if type(Id) ~= "number" or type(RawImageRectSize) ~= "table" or type(RawImageRectOffset) ~= "table" then
        return
    end

    local Url = "rbxassetid://" .. Id
    local ImageRectSize = Vector2.new(RawImageRectSize[1], RawImageRectSize[2])
    local ImageRectOffset = Vector2.new(RawImageRectOffset[1], RawImageRectOffset[2])

    local Asset = {
        Id = Id,
        Url = Url,
        ImageRectSize = ImageRectSize,
        ImageRectOffset = ImageRectOffset,
    }

    return Asset
end

return Lucide
