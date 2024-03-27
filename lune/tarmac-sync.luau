-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>
-- Yes, this gets a bit hacky; we're reading from the manifest directly, so..

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local Log = require("modules/Log")
local StringUtils = require("modules/StringUtils")
local LuaEncode = require("libraries/LuaEncode")

local CodegenPath = "lib/Icons.luau"
local CodegenBasePath = "icons/compiled/"
local IconNameDir = "icons/src/"

local TarmacManifest = serde.decode("toml", fs.readFile("tarmac-manifest.toml"))
local Inputs = TarmacManifest.inputs

assert(Inputs, "Failed to parse tarmac-manifest.toml; `inputs` table not found")

local function RemoveFromTable(inputTable: {[any]: any}, amountToRemove: number)
    for _ = 1, amountToRemove do
        table.remove(inputTable, 1)
    end
end

-- Now let's go thru and read the manifest
local Icons = {}

for FilePath, ImageInfo in Inputs do
    local SplitImagePath = StringUtils.SplitFilePath(FilePath)
    local CodegenLocation = Icons

    if string.match(FilePath, CodegenBasePath) then
        RemoveFromTable(SplitImagePath, #StringUtils.SplitFilePath(CodegenBasePath))
    end

    -- Now we'll loop through the split path and recursively move the pointer ref
    local CurrentLocation: any = CodegenLocation
    for _, Location in SplitImagePath do
        local LocationFileType = StringUtils.FileType(Location)

        if not LocationFileType then -- Directory; no file type
            -- Set dir as a path in codegen when needed
            if not CurrentLocation[Location] then
                CurrentLocation[Location] = {}
            end

            CurrentLocation = CurrentLocation[Location]
        else -- png/jpg etc
            local ImageName = StringUtils.FileNameWithoutExtension(Location)

            local ImageObject = {
                [1] = ImageInfo.id, -- ImageId
            }

            if ImageInfo.slice then
                local ImageRectOffset = ImageInfo.slice[1]
                local ImageRectOffsetBounds = ImageInfo.slice[2]

                local OffsetX, OffsetY = ImageRectOffset[1], ImageRectOffset[2]

                local SizeX = ImageRectOffsetBounds[1] - OffsetX
                local SizeY = ImageRectOffsetBounds[2] - OffsetY

                ImageObject[2] = {SizeX, SizeY} -- ImageRectSize
                ImageObject[3] = {OffsetX, OffsetY} -- ImageRectOffset
            end

            CurrentLocation[ImageName] = ImageObject
        end
    end
end

local IconNames = {}
for _, IconFileName in fs.readDir(IconNameDir) do
    table.insert(IconNames, StringUtils.FileNameWithoutExtension(IconFileName))
end

Log.Info(`Total # of icons: {#IconNames}`)

fs.writeFile(
    CodegenPath,
    `-- This file was automatically @generated and not intended for manual editing\n--!nocheck\n\nreturn ` ..
    LuaEncode(Icons) ..
    "\n"
)

Log.Info(`Wrote to file "{CodegenPath}"`)
