-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local process = require("@lune/process")

local Log = require("modules/Log")
local CommandUtils = require("modules/CommandUtils")
local StringUtils = require("modules/StringUtils")
local Run = require("modules/Run")
local ParseArgs = require("modules/ParseArgs")

local SizesToExport = {"48", "256"}

CommandUtils.CheckCommands({"inkscape", "convert"})

if process.os ~= "linux" then
    Log.Warn("Due to the command syntax used, this build script was designed with only Linux use supported; you don't appear to be running Linux, do you still wish to proceed?")
    local ShouldContinue = stdio.prompt("confirm", "")
    
    if not ShouldContinue then
        return
    end
end

local Options = ParseArgs(process.args, {
    ["icons-folder"] = {"string", "icons/"},
    ["skip-existing"] = {"boolean", true},
})

local IconsFolder = Options["icons-folder"]
local SkipExisting = Options["skip-existing"]

if string.sub(IconsFolder, #IconsFolder) == "/" then
    IconsFolder = string.sub(IconsFolder, #IconsFolder - 1)
end

local SourceFolder = `{IconsFolder}/src`
local CompiledFolder = `{IconsFolder}/compiled`

assert(fs.isDir(IconsFolder), `Icons folder not found at "{process.cwd}{IconsFolder}"`)
assert(fs.isDir(SourceFolder), `Icon SVG sources not found at "{process.cwd}{SourceFolder}"`)

local NumberOfSourceIcons = #fs.readDir(SourceFolder)

if not SkipExisting and fs.isDir(SourceFolder) then
    Log.Warn(`The "{SourceFolder}" directory already exists, do you want to remove it and continue?`)
    local ShouldRemove = stdio.prompt("confirm", "")
    
    if not ShouldRemove then
        return
    end

    fs.removeDir(SourceFolder)
end

if not fs.isDir(SourceFolder) then
    fs.writeDir(SourceFolder)
end

-- Loop through source SVGs
for _, SizeToExport in SizesToExport do
    local SizeFolder = `{CompiledFolder}/{SizeToExport}px`
    if not fs.isDir(SizeFolder) then
        fs.writeDir(SizeFolder)
    end

    for _, FileName in fs.readDir(SourceFolder) do
        if StringUtils.FileType(FileName) ~= "svg" then
            continue
        end

        local IconName = StringUtils.FileNameWithoutExtension(FileName)
        local PNGPath = `{SizeFolder}/{IconName}.png`

        if SkipExisting and fs.isFile(PNGPath) then
            continue
        end

        Run(`inkscape -w {SizeToExport} -h {SizeToExport} --export-type="png" -o - {SourceFolder}/{FileName}`
        ..  ` | convert - -channel RGB -negate {SizeFolder}/{IconName}.png`)

        Log.Info(`Progress (Of @{SizeToExport}px): {#fs.readDir(SizeFolder)}/{NumberOfSourceIcons}`)
    end
end
