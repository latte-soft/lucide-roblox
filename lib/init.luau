-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

export type Asset = {
    Id: number, -- 123456789
    Url: string, -- "rbxassetid://123456789"
    RectSize: Vector2, -- Vector2.new(48, 48)
    RectOffset: Vector2, -- Vector2.new(648, 266)
}

local Icons = require(script.Icons)

local ContentProvider = game:GetService("ContentProvider")

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
    print(Asset.RectSize) -- Vector2.new(48, 48)
    print(Asset.RectOffset) -- Vector2.new(0, 771)
    ```
]]
function Lucide.GetAsset(iconName: string, inputSize: number?, preload: boolean?): Asset?
    local InputSize = if inputSize == nil then 256 else inputSize
    local Preload = if preload == nil then false else preload
end
