-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")
local process = require("@lune/process")

local Log = require("modules/Log")
local Run = require("modules/Run")

local VersionInfo = require("../version-info")

local RojoOutputPath = "build/lucide-roblox.rbxm"
local WaxOutputPath = "build/lucide-roblox.luau"

local CodegenHeader = "--!nolint\n--!nocheck\n--!optimize 2\n--!native\n\n" ..
                      "--[[\n" ..
                      "    lucide-roblox - Library to Use the Lucide Icon Set (https://lucide.dev) in Roblox\n" ..
                      "    MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>\n\n" ..
                      `    Package Version: {VersionInfo.PackageVersion}\n` ..
                      `    Lucide Version: {VersionInfo.LucideVersion}\n` ..
                      "]]\n\n"

if fs.isDir("build") then
    Log.Info("Removing old \"build\" dir..")
    fs.removeDir("build")
end

local StartTime = os.clock()

fs.writeDir("build")

Log.Info("Copying \"LICENSE.md\" to build dir")
fs.copy("LICENSE.md", "build/LICENSE.md")

local function BadExit(message: string)
    Log.Error(message)
    Log.Error("Aborting..")
    process.exit(1)
end

Run(`rojo build -o "{RojoOutputPath}"`, nil, nil, BadExit)
Run(`lune run wax bundle output="{WaxOutputPath}" minify=true extra-offset-lines={#CodegenHeader - 1} ci-mode=true verbose=true`, nil, nil, BadExit)

fs.writeFile(WaxOutputPath, CodegenHeader .. fs.readFile(WaxOutputPath) .. "\n")

Log.Info(`Finished build process in {string.format("%.4f", os.clock() - StartTime)} (seconds)`)
