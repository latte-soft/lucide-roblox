-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

export type Asset = {
    IconName: string, -- "icon-name"
    Id: number, -- 123456789
    Url: string, -- "rbxassetid://123456789"
    ImageRectSize: Vector2, -- Vector2.new(48, 48)
    ImageRectOffset: Vector2, -- Vector2.new(648, 266)
}

local Icons = require(script.Icons)
local VersionInfo = require(script.VersionInfo)

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

local function ApplyToInstance(object: Instance, properties: {[string]: any}): Instance
    if properties then
        for Property, Value in properties do
            if Property ~= "Parent" then
                object[Property] = Value
            end
        end

        if properties.Parent then
            object.Parent = properties.Parent
        end
    end

    return object
end

-- See /version-info.luau
local Lucide = {
    PackageVersion = VersionInfo.PackageVersion,
    LucideVersion = VersionInfo.LucideVersion,
}

-- Add all icon names to an array
do
    local IconNames: {string} = {}
    local _, FirstIconIndex = next(Icons) -- If it's actually `{}`, we're in trouble..
    FirstIconIndex = FirstIconIndex or {}

    for IconName in FirstIconIndex do
        table.insert(IconNames, IconName)
    end

    table.sort(IconNames)
    table.freeze(IconNames)
    Lucide.IconNames = IconNames
end

--[[
    Attempts to retrieve and wrap an asset object from a specified icon name, with
    an optional target icon size argument, fetching the closest to what's supported

    *Will* throw an error if the icon name provided is invalid/not found

    *Example:*
    ```lua
    local Asset = Lucide.GetAsset("server", 48) -- iconSize will default to `256` if not provided
    assert(Asset, "Failed to fetch asset!")

    print(Asset.IconName) -- "server"
    print(Asset.Id) -- 15269177520
    print(Asset.Url) -- "rbxassetid://15269177520"
    print(Asset.ImageRectSize) -- Vector2.new(48, 48)
    print(Asset.ImageRectOffset) -- Vector2.new(0, 771)
    ```
]]
function Lucide.GetAsset(iconName: string, iconSize: number?): Asset
    local IconSize = if iconSize == nil then 256 else iconSize

    CheckArgTypes("Lucide.GetAsset", {iconName, IconSize}, {
        [1] = {"iconName", "string"},
        [2] = {"iconSize", "number"},
    })

    local IconName = TrimIconIdentifier(iconName)

    -- If reading directly from a UI obj w/ a negative size..?
    if IconSize < 0 then
        IconSize = -IconSize
    end

    local RealSizeIndex = if IconSize <= 48 then "48px" else "256px"
    local IconIndexDict = Icons[RealSizeIndex]

    if not IconIndexDict then
        error("Lucide.GetAsset: Internal error: Failed to find icon index for specified size")
    end

    local RawAsset = IconIndexDict[IconName]
    if not RawAsset then
        error("Lucide.GetAsset: Failed to find icon by the name of \"" .. IconName .. "\" (@" .. RealSizeIndex .. "), perhaps a spelling mistake?", 2)
    end

    local Id = RawAsset[1]
    local RawImageRectSize = RawAsset[2]
    local RawImageRectOffset = RawAsset[3]

    if type(Id) ~= "number" or type(RawImageRectSize) ~= "table" or type(RawImageRectOffset) ~= "table" then
        error("Lucide.GetAsset: Internal error: Invalid auto-generated asset entry")
    end

    local Url = "rbxassetid://" .. Id
    local ImageRectSize = Vector2.new(RawImageRectSize[1], RawImageRectSize[2])
    local ImageRectOffset = Vector2.new(RawImageRectOffset[1], RawImageRectOffset[2])

    local Asset: Asset = {
        IconName = IconName,
        Id = Id,
        Url = Url,
        ImageRectSize = ImageRectSize,
        ImageRectOffset = ImageRectOffset,
    }

    return Asset
end

--[[
    Returns a dictionary of every `Asset` from every icon name in `Lucide.IconNames`

    This could also be useful for, for example, working with a custom asset
    preloading system via `ContentProvider:PreloadAsync()` etc

    *Example:*
    ```lua
    local AllAssets = Lucide.GetAllAssets(256) -- Also defaults to `256`, just like `Lucide.GetAsset()`

    for _, Asset in AllAssets do
        print(Asset.IconName, Asset.Url)
    end
    ```
]]
function Lucide.GetAllAssets(inputSize: number?): {Asset}
    local InputSize = if inputSize == nil then 256 else inputSize

    CheckArgTypes("Lucide.GetAllAssets", {InputSize}, {
        [1] = {"inputSize", "number"},
    })

    local Assets = {}

    for _, IconName in Lucide.IconNames do
        local Asset = Lucide.GetAsset(IconName, InputSize)
        if Asset then
            table.insert(Assets, Asset)
        end
    end

    -- `Lucide.IconNames` is already pre-sorted
    return Assets
end

--[[
    Wrapper around `Lucide.GetAsset()` that fetches asset info for the specified
    icon name and size, anc creates an `ImageLabel` Instance. Accepts an additional
    optional argument for providing a table of properties to automatically apply
    after the asset has been applied to said `ImageLabel`

    Without providing any extra property overrides, the icon is colored to its
    default of #FFFFFF, and theinput from the `imageSize` argument is the
    offset value of `ImageLabel.Size`

    Throws an error under the same terms as `Lucide.GetAsset()`

    *Example:*
    ```lua
    local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
    local ScreenGui = Instance.new("ScreenGui")

    Lucide.ImageLabel("server-crash", 256, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),

        Parent = ScreenGui,
    })

    ScreenGui.Parent = PlayerGui
    ```
]]
function Lucide.ImageLabel(iconName: string, imageSize: number?, propertyOverrides: {[string]: any}?): ImageLabel
    local ImageSize = if imageSize == nil then 256 else imageSize
    local PropertyOverrides = if propertyOverrides == nil then {} else propertyOverrides

    CheckArgTypes("Lucide.ImageLabel", {iconName, imageSize, propertyOverrides}, {
        [1] = {"iconName", "string"},
        [2] = {"imageSize", "number"},
        [3] = {"propertyOverrides", "table"}
    })

    local Asset = Lucide.GetAsset(iconName, ImageSize)

    local ImageLabel = ApplyToInstance(Instance.new("ImageLabel"), {
        Name = Asset.IconName,

        Size = UDim2.fromOffset(ImageSize, ImageSize),

        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Image = Asset.Url,
        ImageRectSize = Asset.ImageRectSize,
        ImageRectOffset = Asset.ImageRectOffset,
        ImageColor3 = Color3.new(1, 1, 1), -- #FFFFFF
        ScaleType = Enum.ScaleType.Fit,
    })

    -- Apply any provided overrides
    ApplyToInstance(ImageLabel, PropertyOverrides)

    return ImageLabel
end

table.freeze(Lucide)
return Lucide
