--!nolint
--!nocheck
--!native
--!optimize 2

--[[
    Wax - A Fast Runtime Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics
    MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

    Wax Version: 0.3.6
]]

------------------------------------------------------------------------------------------------------

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

if string.sub(_VERSION, 1, 4) ~= "Lune" then
    print("!! Wax doesn't appear to be running on Lune (https://lune-org.github.io/docs), which this script requires, exitting..")
    return
end

do
    -- Minimum "recommended" ver
    local MajorRec,
          MinorRec,
          PatchRec = 0, 7, 11

    local Major,
          Minor,
          Patch = string.match(_VERSION, "Lune (%d+).(%d+).(%d+)")

    Major, Minor, Patch = tonumber(Major), tonumber(Minor), tonumber(Patch)

    if not Major then
        print(`! Can't parse Lune's version on the assumed format from "{_VERSION}", continuing anyway..\n`)
    else
        _G.LuneVersion = `{Major}.{Minor}.{Patch}`
        if Major < MajorRec or Minor < MinorRec or Patch < PatchRec then
            print(`! Lune version "{_G.LuneVersion}" detected, Wax currently recommends Lune {MajorRec}.{MinorRec}.{PatchRec} or higher, continuing anyway..\n`)
        end
    end
end

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local BundleModel = require("lib/BundleModel")

local Log = require("lib/Log")
local StringUtils = require("lib/StringUtils")
local CommandUtils = require("lib/CommandUtils")
local Run = require("lib/Run")
local ParseArgs = require("lib/ParseArgs")

local Version = require("lib/data/Version")
local DefaultDarkluaConfig = require("lib/data/DefaultDarkluaConfig")

local UsageMessage = `Wax {Version}\n` .. [[
A Fast Runtime Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics

USAGE:
    lune wax [subcommand] [options]

* When no subcommand is provided, this usage message is displayed
* Provide all options in the following format (no "--" flag prefix): option=value

SUBCOMMANDS:
    help      Displays this usage message

    version   Displays Wax's version

    bundle    Builds a bundled script file from a given Roblox model (*.rbxm/*.rbxmx)
              or Rojo project file (*.project.json, requires the `rojo` command
              available in your PATH environment variable), to an output path

      OPTIONS for `bundle`:
      * input[="default.project.json"]
            The input Roblox model (*.rbxm/*.rbxmx) or Rojo project (*.project.json) file
            path for Wax to bundle from

      * output[="{input-filename}.lua"]
            The final output file path (must end in .lua or .luau) for the bundled script

      * minify[=false]
            If codegen output should be "minified", which also omits any runtime line
            debugging info (offsets). For 'full' codegen minification (outside of just
            LuaEncode's table output), you must have the `darklua` command available in
            your PATH environment variable.
            Additionally, with Darklua, if a ".darklua.json/json5" file isn't found in the
            CWD (your dir "position" in your terminal), it'll use the default configuration
            we provide (see `lune/lib/data/DefaultDarkluaConfig.luau`)
    
      * env-name[="WaxRuntime"]
            The name of the "environment" of the bundled script. This is the "name" of
            the root object (like the `game` DataModel in Roblox) and displays in virtual
            runtime errors (e.g. "[WaxRuntime].Script:1: Some error message")
    
      * darklua-config-path[=(".darklua.json", ".darklua.json5")]
            When `minify` is set as true, this path can be used to directly pass your own
            Darklua config file's path, instead of only checking for the default paths
            it looks for

      * temp-dir-base[="{output-dir}"]
            If you're providing a Rojo project file as input or minifying with Darklua,
            a temporary directory is created inside of this directory path, and is removed
            by the time Wax has completed processing

      * extra-offset-lines[=0]
            (Only applicable to when `minify` is set to false) Internally acknowledges
            any extra lines offset from the top of the script (like if you're adding a
            header of sorts to the codegen) for line debugging info. Ths MUST be exactly
            accurate to its name (*extra* lines, so you may want to do something like
            `#ExtraHeader - 1` if you're using this option)

      * ci-mode[=false]
            (*Primarily* for automated CI pipelines or deployment systems) Never gives
            any user input prompts, and will *always* exit with a `1` status code upon an
            'error' or warning during the build process

      * verbose[=true]
            "Verbose" (detailed) output logging from CLI/bundler
]]

-- Flush out any other previous ANSI nonsense
stdio.write(stdio.color("reset") .. stdio.style("reset"))

local function EncodeShellData(shellData: string): string
    return if process.os == "windows" then
        shellData -- I swear, Windows makes everything worse
    else '"' .. StringUtils.SerializeStringData(shellData) .. '"'
end

local CommandArgs = table.clone(process.args)
local Subcommand = table.remove(CommandArgs, 1)

if not Subcommand then
    print(UsageMessage)
    return
end

Subcommand = string.lower(Subcommand)

if Subcommand == "help" then
    print(UsageMessage)
    return
elseif Subcommand == "version" then
    print(`Wax v{Version}`)
    return
elseif Subcommand == "bundle" then
    -- Below is our user-proofing hell!
    -- “An idiot admires complexity, a genius admires simplicity" - Terry A Davis

    -- Parse and init default CLI options
    local Options = ParseArgs(CommandArgs, {
        -- Option = {Type, DefaultValue, IsRequired?}
        ["input"] = {"string", "default.project.json"},
        ["output"] = {"string", nil},
        ["minify"] = {"boolean", false},
        ["env-name"] = {"string", nil}, -- BundleModel() internally defaults to "WaxRuntime"
        ["darklua-config-path"] = {"string", nil},
        ["temp-dir-base"] = {"string", nil},
        ["extra-offset-lines"] = {"number", 0},
        ["ci-mode"] = {"boolean", false},
        ["verbose"] = {"boolean", true},
    }, UsageMessage)

    local Verbose = Options["verbose"]
    local CIMode = Options["ci-mode"]

    local Minify = Options["minify"]
    local EnvName = Options["env-name"]

    local function RunIfVerbose(f, ...)
        if Verbose then
            f(...)
        end
    end

    -- These is being defined here since we're utilizing RunIfVerbose()
    local function WriteFile(path: string, contents: string)
        RunIfVerbose(Log.Info, `Writing to "{path}"..`)
        fs.writeFile(path, contents)
    end

    local function RemoveFile(path: string)
        RunIfVerbose(Log.Info, `Deleting file at "{path}"..`)
        fs.removeFile(path)
    end

    local function WriteDir(path: string)
        RunIfVerbose(Log.Info, `Creating directory at "{path}"..`)
        fs.writeDir(path)
    end

    local function RemoveDir(path: string)
        RunIfVerbose(Log.Info, `Removing directory at "{path}"..`)
        fs.removeDir(path)
    end


    -- `input` option handling:

    local Input = Options["input"]

    if not fs.isFile(Input) then
        Log.Error(`Failed to find file path "{Input}" from \`input\` option\n`)
        print(UsageMessage)
        process.exit(1)
    end

    local InputDirectory = StringUtils.DirectoryOfFilePath(Input) or ""

    local InputLower = string.lower(Input)
    local InputType = if string.sub(InputLower, -5) == ".rbxm" then
            ".rbxm" -- Roblox model (binary)
        elseif string.sub(InputLower, -6) == ".rbxmx" then
            ".rbxmx" -- Roblox model (XML)
        elseif string.sub(InputLower, -13) == ".project.json" then
            ".project.json" -- Rojo project file
        else nil

    if not InputType then
        Log.Error(`Invalid file type ".{StringUtils.FileType(Input)}" for \`input\`, expected [".rbxm", ".rbxmx", ".project.json"]\n`)
        print(UsageMessage)
        process.exit(1)
    end

    -- `output` option handling:

    local Output = Options["output"]

    if not Output then
        local NewOutputBase

        if InputType == ".project.json" then
            local ParseSuccess, ErrorOrParsed = pcall(serde.decode, "json" :: "json", fs.readFile(Input))

            if not ParseSuccess then
                Log.Error(`Failed to parse Rojo project file at "{Input}": {ErrorOrParsed}`)
                process.exit(1)
            end

            if not ErrorOrParsed.name or type(ErrorOrParsed.name) ~= "string" then
                Log.Warn(`Couldn't find proper "name" entry at the root of Rojo project file at "{Input}", using its file name base instead..`)
            else
                NewOutputBase = ErrorOrParsed.name
            end
        end

        -- If it's not a Rojo project file or `NewOutputBase` still hasn't been set..
        if not NewOutputBase then
            NewOutputBase = StringUtils.FilePathWithoutExtension(Input, false)
        end
        
        if not NewOutputBase then
            Log.InternalError(`Failed to get file path without the extension for "{Output}"`)
            process.exit(1)
        end

        NewOutputBase ..= ".wax.lua"
        Output = InputDirectory .. NewOutputBase
    else
        local OutputFileType = StringUtils.FileType(Output)
        local DirectoryOfOutput = StringUtils.DirectoryOfFilePath(Output)

        if not DirectoryOfOutput then
            Log.Error(`\`output\` file path given, "{Output}" not a valid path\n`)
            print(UsageMessage)
            process.exit(1)
        elseif not fs.isDir(DirectoryOfOutput) then
            Log.Error(`Directory of \`output\` file path given, "{DirectoryOfOutput}" not found/invalid\n`)
            print(UsageMessage)
            process.exit(1)
        elseif not OutputFileType or not table.find({"lua", "luau"}, OutputFileType) then
            local FileTypeDisplay = if OutputFileType == "" then "<empty>" else "." .. OutputFileType

            Log.Error(`File type of \`output\` ({FileTypeDisplay}) invalid, expected [".lua", ".luau"]\n`)
            print(UsageMessage)
            process.exit(1)
        end
    end

    local OutputFileName = StringUtils.FileNameFromPath(Output)
    if not OutputFileName then
        Log.InternalError(`Failed to parse file name from output file path "{Output}"`)
        process.exit(1)
    end

    local OutputFileNameWithoutExtension = StringUtils.FileNameWithoutExtension(OutputFileName, false)
    if not OutputFileNameWithoutExtension then
        Log.InternalError(`Failed to parse file name without its extension from "{OutputFileName}"`)
        process.exit(1)
    end

    -- `darklua-config-path` option handling:

    DarkluaConfigPath = Options["darklua-config-path"]

    if DarkluaConfigPath and not fs.isFile(DarkluaConfigPath) then
        Log.Error(`File path given for \`darklua-config-path\`, "{DarkluaConfigPath}" not found`)
        process.exit(1)
    end

    -- `temp-dir-base` option handling:

    local TempDirBase = Options["temp-dir-base"]

    if not TempDirBase then
        TempDirBase = StringUtils.DirectoryOfFilePath(Output)
    elseif not fs.isDir(TempDirBase) then
        Log.Error(`\`temp-dir-base\` directory given, "{TempDirBase}" not found/invalid\n`)
        print(UsageMessage)
        process.exit(1)
    end

    if not string.match(TempDirBase, "[/\\]$") then
        TempDirBase ..= "/"
    end

    -- The actual temp dir path we'll be using
    local TempDir = TempDirBase .. ".wax-tmp/"

    -- If it already exists for some reason..?
    if fs.isDir(TempDir) then
        RunIfVerbose(Log.Info, `Old .wax-tmp dir at "{TempDir}" already exists, removing..`)
        fs.removeDir(TempDir)
    end

    ExtraOffsetLines = Options["extra-offset-lines"]
    if ExtraOffsetLines < 0 then
        Log.Error(`Option \`extra-offset-lines\` ({ExtraOffsetLines}) cannot be less than 0\n`)
        print(UsageMessage)
        process.exit(1)
    end
    if not Minify and ExtraOffsetLines > 0 then
        RunIfVerbose(Log.Info, `(Note) Runtime line debugging *will* display with the assumption that \`{ExtraOffsetLines}\` lines will be added to the output by you manually; make sure this is EXACT, as debugging info could be inaccurate otherwise`)
    end

    -- Now we'll start non-option processing

    -- Now, we may need to eventually worry about exitting upon random unhandled errors
    -- since we may be creating a temp dir in the user's directory
    local function BadExit(message: string?)
        if message then
            Log.Error(message)
        end

        if fs.isDir(TempDir) then
            RemoveDir(TempDir)
        end

        process.exit(1)
    end

    -- Check for necessary commands
    if InputType == ".project.json" and not CommandUtils.CommandExists("rojo") then
        Log.Error(`Rojo project file given for input ("{Input}"), but the \`rojo\` command wasn't found in your PATH environment variable..\n`)
        print(UsageMessage)
        process.exit(1)
    end

    local DarkluaBinaryExists = CommandUtils.CommandExists("darklua")
    if Minify and not DarkluaBinaryExists then
        Log.Warn("The `minify` option is set as true, but the `darklua` command wasn't found in your PATH environment variable.. (Wax won't be able to completely minify the output)")
        if not CIMode then
            local ShouldContinue = stdio.prompt("confirm", "Continue anyway?")
            if not ShouldContinue then
                BadExit()
            end
        end
    end

    -- Create tmp dir if applicable
    if InputType == ".project.json" or (Minify and DarkluaBinaryExists) then
        WriteDir(TempDir)
    end

    local ModelRoot

    if table.find({".rbxm", ".rbxmx"}, InputType) then -- Roblox model file (direct)
        RunIfVerbose(Log.Info, `Deserializing Roblox model file at "{Input}"..`)
        local Success, ModelRootOrError = pcall(roblox.deserializeModel, fs.readFile(Input))

        if not Success then -- ModelRootOrError is an err msg
            BadExit(`Failed to deserialize Roblox model file at "{Input}": {ModelRootOrError}`)
        end

        -- Here, it's just the ModelRoot return ofc
        ModelRoot = ModelRootOrError
    elseif InputType == ".project.json" then -- Rojo project file
        local ModelOutputFileName = TempDir .. OutputFileNameWithoutExtension .. ".o.rbxm"
        RunIfVerbose(Log.Info, `Building from Rojo project file to "{ModelOutputFileName}"`)

        Run(
            "rojo", {
                "build",
                "-o",
                EncodeShellData(ModelOutputFileName),
                EncodeShellData(Input),
            },
            false,
            BadExit -- Run() has an option to provide an err handler ourselves
        )

        ModelRoot = roblox.deserializeModel(fs.readFile(ModelOutputFileName))
        RemoveFile(ModelOutputFileName) -- Remove temporary rbxm
    end

    RunIfVerbose(Log.Info, "Starting BundleModel() process from deserialized model data")
    local BundleSuccess, CodegenOutputOrError, FailedCompilations = pcall(BundleModel, ModelRoot, EnvName, Minify, ExtraOffsetLines, Verbose)

    if not BundleSuccess then
        BadExit(`Error during BundleModel() process: {CodegenOutputOrError}`)
    end

    if Minify and DarkluaBinaryExists then
        local TempOutputFilePath = TempDir .. OutputFileName
        WriteFile(TempOutputFilePath, CodegenOutputOrError)

        RunIfVerbose(Log.Info, "Starting minification process with Darklua")

        local ExtraDarkluaProcessArgs = {}

        -- Check for possible default Darklua cfg files under CWD
        local TempDarkluaConfigPath = TempDir .. ".darklua.json"
        local TempDarkluaConfigWasAdded = false

        if DarkluaConfigPath then
            table.insert(ExtraDarkluaProcessArgs, `-c={EncodeShellData(DarkluaConfigPath)}`)
        elseif not fs.isFile(".darklua.json") and not fs.isFile(".darklua.json5") then
            RunIfVerbose(Log.Info, `No default Darklua config file found in CWD; creating our default config at "{TempDarkluaConfigPath}"`)
            WriteFile(TempDarkluaConfigPath, DefaultDarkluaConfig)
            TempDarkluaConfigWasAdded = true

            table.insert(ExtraDarkluaProcessArgs, `-c={EncodeShellData(TempDarkluaConfigPath)}`)
        end

        Run("darklua", {
            "process",
            EncodeShellData(TempOutputFilePath),
            EncodeShellData(Output),
            unpack(ExtraDarkluaProcessArgs),
        })

        RemoveFile(TempOutputFilePath)
        if TempDarkluaConfigWasAdded then
            RemoveFile(TempDarkluaConfigPath)
        end
    else
        -- Just write directly
        WriteFile(Output, CodegenOutputOrError)
    end

    -- We're now completely finished!
    if fs.isDir(TempDir) then
        RemoveDir(TempDir)
    end

    -- Let the user *clearly* know if there were any user-fault compiler errors
    if FailedCompilations > 0 then
        Log.Warn(`\nWARNING: {FailedCompilations} scripts failed to compile ahead-of-time (CHECK FULL BUILD LOG ABOVE FOR MORE DETAILS); these will throw errors at runtime upon being loaded, detailing said compilation errors.`)

        if CIMode then
            process.exit(1)
        end
    end
else
    Log.Error(`Subcommand "{Subcommand}" invalid, see usage for all valid subcommands:\n`)
    print(UsageMessage)
    process.exit(1)
end

end)() end,
    [3] = function()local wax,script,require=ImportGlobals(3)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local luau = require("@lune/luau")
local roblox = require("@lune/roblox")

local Log = require("Log")
local StringUtils = require("StringUtils")

local LuaEncode = require("libraries/LuaEncode")

-- Init script template for codegen (in this, we'll maintain 5.1 *syntax* compat
-- for optional compilation to vanilla Lua 5.1x bytecode format)
local InitScriptTemplate = require("data/Template")

local Version = require("data/Version")

local ClassNameIdKeys = {
    Folder = 1,
    ModuleScript = 2,
    Script = 3,
    LocalScript = 4,
    StringValue = 5,
}

-- Building codegen directly from model data (from .rbxm/.rbxmx) or a deserialized
-- object using Lune's `roblox` library
local function BundleModel(modelData: string | {roblox.Instance}, envName: string?, minifyCodegen: boolean?, extraLinesToOffset: number?, verbose: boolean?): (string, number)
    local EnvName = envName or "WaxRuntime"
    local MinifyCodegen = if minifyCodegen == nil then true else minifyCodegen
    local ExtraLinesToOffset = extraLinesToOffset or 0
    local Verbose = if verbose == nil then true else verbose

    -- Same as in Wax CLI
    local function RunIfVerbose(f, ...)
        if Verbose then
            f(...)
        end
    end

    local LineDebugging = MinifyCodegen == false

    local ModelRoot = if type(modelData) == "string" then
        roblox.deserializeModel(modelData)
    else modelData

    -- We'll track how long it takes for us to read the entire object tree, with all
    -- other various processes included
    local ReadStartTime = os.clock()

    local FailedCompilations = 0

    -- We'll initialize the output object tree, then walk through what we need to
    local ObjectTree = {}
    local ClosureBindings = {} -- [RefId] = Closure
    local ClosureSourceLineCounts = {} -- [RefId] = LineCount

    local ScrapedInstanceTree = {} -- [RealRef] = {Child, ...}
    local RefIds = {} -- [RefId] = RealRef

    -- Recursive function to actually walk through the real instance tree, and assign refs
    local function ScrapeInstanceChildren(instance)
        -- Add a reference id for this instance
        table.insert(RefIds, instance)

        local ScrapedChildren = {}
        for _, Child in instance:GetChildren() do
            ScrapedChildren[Child] = ScrapeInstanceChildren(Child)
        end

        return ScrapedChildren
    end

    -- Initialize the scraped instance tree and assign all refs from root
    for _, RealInstance in ModelRoot do
        ScrapedInstanceTree[RealInstance] = ScrapeInstanceChildren(RealInstance)
    end

    -- Now, we'll recursively create the fake object tree
    local function CreateObjectTree(instance, children, currentPathString: string?)
        currentPathString = currentPathString or instance.Name

        local RefId = table.find(RefIds, instance)
        local ClassName = instance.ClassName

        local ClassNameId = ClassNameIdKeys[ClassName]
        if not ClassNameId then
            RunIfVerbose(Log.Info, `Skipping instance of ClassName "{ClassName}", as it isn't supported in bundling`)
            return
        end

        local InstanceIsABaseScript = ClassName == "LocalScript" or ClassName == "Script"
        local InstanceIsAScript = InstanceIsABaseScript or ClassName == "ModuleScript"

        --[[
            {
                [1] = RefId,
                [2] = ClassName,
                [3] = Properties,
                [4] = Children?
            }
        ]]

        local InstanceObject = {
            [1] = RefId,
            [2] = ClassNameId,
        }

        -- If it's statically disabled, we just won't include the closure to run
        if InstanceIsAScript and not (InstanceIsABaseScript and instance.Disabled) then
            local ScriptSource = instance.Source

            RunIfVerbose(Log.Info, `Compile-checking {instance.ClassName} "{currentPathString}"..`)
            local CompileSuccess, CompileError = pcall(luau.compile, ScriptSource)

            if CompileSuccess then
                -- The added line here is the "\nend" below every arbitrary closure
                ClosureSourceLineCounts[RefId] = StringUtils.LineCount(ScriptSource) + 1

                -- We're using `FunctionsReturnRaw` on LuaEncode later, this will set the return
                -- to the rew value, which is the script closure
                ClosureBindings[RefId] = function()
                    return "function()local wax,script,require=ImportGlobals(" .. RefId .. ")local ImportGlobals return (function(...)" .. ScriptSource .. "\nend)() end"
                end
            else
                -- The `18` index in the substring call is for after the end of, e.g. "runtime error: :"
                -- After that, we have, e.g. "1: ", which is the line num. This can be higher, of course
                local FirstLineOfError = string.match(tostring(CompileError), "%w* ?:%d*: ?([^\n]*)\n")
                Log.Warn(`WARNING: {instance.ClassName} "{currentPathString}" failed to compile: {FirstLineOfError or "[Failed to parse compiler error]"}`)
                FailedCompilations += 1

                ClosureSourceLineCounts[RefId] = 1 -- Guaranteed 1 line; see below lol

                ClosureBindings[RefId] = function()
                    return `function()error("[AOT COMPILER ERROR] {StringUtils.SerializeStringData(FirstLineOfError)}")end`
                end
            end
        end

        -- Add any properties
        local Properties = {[1] = instance.Name} -- For byte preservation (lol) the name is just set as the property index 1, and not "Name"

        if ClassName == "StringValue" then
            Properties.Value = instance.Value
        end

        -- The init script will assume the `Name` is the same as the `ClassName` if not included
        if instance.Name ~= ClassName then
            InstanceObject[3] = Properties
        end

        -- Recursively add children
        if next(children) then
            local ObjectChildren = {}

            for Child, ChildrenOfChild in children do
                local ChildObjectTree = CreateObjectTree(Child, ChildrenOfChild, `{currentPathString}.{Child.Name}`)
                if ChildObjectTree then
                    table.insert(ObjectChildren, ChildObjectTree)
                end
            end

            InstanceObject[4] = ObjectChildren
        end

        return InstanceObject
    end

    for RealInstance, Children in ScrapedInstanceTree do
        local ChildObjectTree = CreateObjectTree(RealInstance, Children)

        if ChildObjectTree then
            table.insert(ObjectTree, ChildObjectTree)
        end
    end

    local LineOffsets = {}
    if LineDebugging then
        -- Starts at line 6, where the first closure func start should be
        local CurrentLineOffset = ExtraLinesToOffset + 6

        for RefId, LineCount in ClosureSourceLineCounts do
            LineOffsets[RefId] = CurrentLineOffset
            CurrentLineOffset += LineCount
        end
    end

    -- Now we're done reading everything!
    local ReadEndTime = os.clock()
    RunIfVerbose(Log.Info, `Finished reading object tree! Total build time: {string.format("%.4f", ReadEndTime - ReadStartTime)} (seconds)`)

    local Prettify = if MinifyCodegen == false then true else false

    local SerializedObjectTree = LuaEncode(ObjectTree, {
        Prettify = Prettify,
        StackLimit = math.huge,
    })

    local SerializedClosureBindings = LuaEncode(ClosureBindings, {
        Prettify = Prettify,
        FunctionsReturnRaw = true, -- For Script.Source function closures
    })

    local SerializedLineOffsets = if not LineDebugging then
        "nil"
    else
        LuaEncode(LineOffsets, {
            Prettify = Prettify,
        })

    local CodegenOutput = StringUtils.Replace(InitScriptTemplate, {
        Version = StringUtils.SerializeStringData(Version),
        EnvName = StringUtils.SerializeStringData(EnvName),
        ObjectTree = SerializedObjectTree,
        ClosureBindings = SerializedClosureBindings,
        LineOffsets = SerializedLineOffsets,
    })

    return CodegenOutput, FailedCompilations
end

return BundleModel

end)() end,
    [4] = function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local process = require("@lune/process")

local CommandUtils = {}

-- We'll check some required commands in a sec
function CommandUtils.CommandExists(binary: string): boolean
    if process.os ~= "windows" then
        -- Unix-compliance is simple!
        return process.spawn("type", {binary}, {shell = true}).ok -- Return from status code directly
    end

    -- I hate Windows
    return true
end

function CommandUtils.CheckCommands(requiredCommands: {string})
    -- Check required commands to continue script exec
    for _, Command in requiredCommands do
        assert(CommandUtils.CommandExists(Command), `Required command "{Command}" no found in your PATH environment variable, is it not installed?`)
    end
end

return CommandUtils

end)() end,
    [5] = function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local stdio = require("@lune/stdio")

local ANSI = {
    Reset = stdio.color("reset") .. stdio.style("reset"),

    Red = stdio.color("red"),
    Yellow = stdio.color("yellow"),

    Bold = stdio.style("bold"),
}

local Log = {}

function Log.Info(message: string, ending: string?)
    ending = ending or "\n"
    stdio.write(`∙ {message}{ending}`)
end

function Log.Error(message: string, ending: string?)
    ending = ending or "\n"
    stdio.write(`{ANSI.Bold .. ANSI.Red}∙ {message}{ANSI.Reset}{ending}`)
end

function Log.Warn(message: string, ending: string?)
    ending = ending or "\n"
    stdio.write(`{ANSI.Bold .. ANSI.Yellow}∙ {message}{ANSI.Reset}{ending}`)
end

function Log.InternalError(message: string, ending: string?)
    Log.Error("[INTERNAL ERROR] " .. message, ending)
end

return Log

end)() end,
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

type OptionsInput = {[string]: {string | number | boolean | nil}}
type OptionsOutput = {[string]: string | number | boolean | nil}

local process = require("@lune/process")

local Log = require("Log")

local function ParseArgs(args: {string}, optionsTable: OptionsInput, usageMessage: string?): OptionsOutput
    local function ErrorExit()
        if usageMessage then
            print(`\n{usageMessage}`)
        end
        process.exit(1)
    end

    local OptionsOutput = {}

    for _, Arg in args do
        local Option, Value = string.match(Arg, "([%w%-_]+)=(.+)")

        if not Option then
            Log.Error(`Command argument given, "{Arg}" not in the proper \`option=value\` format, aborting..`)
            ErrorExit()
        end

        local OptionDetails = optionsTable[Option]

        if OptionDetails == nil then -- Then it isn't a defined arg
            Log.Error(`"{Option}" isn't a valid option"`)
            ErrorExit()
        end

        local OptionType = OptionDetails[1]

        if OptionType == "boolean" then
            Value = string.lower(Value)
            Value = if Value == "true" then true elseif Value == "false" then false else nil

            if Value == nil then
                Log.Error(`"{Value}" isn't a valid boolean type; expected "true" or "false"`)
                ErrorExit()
            end
        elseif OptionType == "number" then
            Value = tonumber(Value)
            if not Value then
                Log.Error(`Failed to convert given input "{Value}" to a number value`)
                ErrorExit()
            end
        end

        OptionsOutput[Option] = Value
    end

    for Option, Details in optionsTable do
        local DefaultValue = Details[2]
        local IsRequired = Details[3] or false

        if not OptionsOutput[Option] then
            if IsRequired then
                Log.Error(`Option "{Option}" required but not provided`)
                ErrorExit()
            end

            OptionsOutput[Option] = DefaultValue
        end
    end

    return OptionsOutput
end

return ParseArgs

end)() end,
    [7] = function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local process = require("@lune/process")

local Log = require("Log")

local function Run(command: string, args: {string}?, directRun: boolean?, errorHandler: (string?) -> ()?): process.SpawnResult
    local Args = args or {}
    local DirectRun = if directRun == nil then false else directRun

    if not DirectRun then
        if #Args == 0 then
            Log.Info(`> {command}`)
        else
            Log.Info(`> {command} {table.concat(Args, " ")}`)
        end
    end

    local Result = process.spawn(command, args, {
        shell = if process.os ~= "windows" then true else nil,
        stdio = if DirectRun then "default" else "inherit",
    })

    if not Result.ok and errorHandler then
        errorHandler(`Command above failed with status code {Result.code}`)
    end

    return Result
end

return Run

end)() end,
    [8] = function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local StringUtils = {}

function StringUtils.FileType(filePath: string): string?
    local Match = string.match(filePath, ".%.([^%.]+)$")
    if Match then
        Match = string.lower(Match)
    end

    return Match
end

function StringUtils.FileNameFromPath(filePath: string): string?
    return string.match(filePath, "[^/\\]+$")
end

function StringUtils.FileNameWithoutExtension(fileName: string, onlyTheLastDot: boolean?): string?
    onlyTheLastDot = if onlyTheLastDot == nil then true else onlyTheLastDot

    if onlyTheLastDot then
        return string.match(fileName, "^(.+)%.")
    else
        return string.match(fileName, "^%.?[^%.]+")
    end
end

function StringUtils.FilePathWithoutExtension(filePath: string, onlyTheLastDot: boolean?): string?
    local FilePathDirectory = StringUtils.DirectoryOfFilePath(filePath)
    local FileName = StringUtils.FileNameFromPath(filePath)

    if not FilePathDirectory or not FileName then
        return
    end

    local FileNameStripped = StringUtils.FileNameWithoutExtension(FileName, onlyTheLastDot)
    if not FileNameStripped then
        return
    end

    return FilePathDirectory .. FileNameStripped
end

function StringUtils.DirectoryOfFilePath(filePath: string): string?
    local Directory = string.match(filePath, "^.*[/\\]")
    if not Directory or Directory == "" then
        Directory = "./"
    end

    return Directory
end

function StringUtils.LineCount(input: string): number
    local Lines = 1
    for _ in string.gmatch(input, "\n") do
        Lines += 1
    end

    return Lines
end

function StringUtils.Replace(inputString: string, replacements: {[string]: string}): string
    return string.gsub(inputString, "${([A-Za-z_][A-Za-z0-9_]*)}", replacements)
end

do
    -- These are control characters to be encoded in a certain way in Lua rather than just a byte
    -- escape (e.g. "\n" -> "\10")
    local SpecialCharacters = {
        ["\""] = "\\\"", -- Double-Quote
        ["\\"] = "\\\\", -- (Literal) Backslash
        -- Special ASCII control char codes
        ["\a"] = "\\a", -- Bell; ASCII #7
        ["\b"] = "\\b", -- Backspace; ASCII #8
        ["\t"] = "\\t", -- Horizontal-Tab; ASCII #9
        ["\n"] = "\\n", -- Newline; ASCII #10
        ["\v"] = "\\v", -- Vertical-Tab; ASCII #11
        ["\f"] = "\\f", -- Form-Feed; ASCII #12
        ["\r"] = "\\r", -- Carriage-Return; ASCII #13
    }

    -- We need to assign all extra normal byte escapes for runtime optimization
    for Index = 0, 255 do
        local Character = string.char(Index)

        if not SpecialCharacters[Character] and (Index < 32 or Index > 126) then
            SpecialCharacters[Character] = "\\" .. Index
        end
    end

    function StringUtils.SerializeStringData(inputString: string): string
        -- FYI; We can't do "\0-\31" in Lua 5.1 (Only Luau/Lua 5.2+) due to an embedded zeros in pattern
        -- issue. See: https://stackoverflow.com/a/22962409
        local Serialized = string.gsub(inputString, "[%z\\\"\1-\31\127-\255]", SpecialCharacters)
        return Serialized
    end
end

return StringUtils

end)() end,
    [10] = function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)return [[
{
    "generator": {
        "name": "dense",
        "column_span": 100
    },
    "rules": [
        "convert_index_to_field",
        "compute_expression",
        "group_local_assignment",
        "filter_after_early_return",
        "remove_comments",
        "remove_empty_do",
        "remove_function_call_parens",
        "remove_nil_declaration",
        "remove_method_definition",
        "remove_spaces",
        "remove_unused_if_branch",
        "remove_unused_while",
        {
            "rule": "rename_variables",
            "include_functions": true
        }
    ]
}]]
end)() end,
    [11] = function()local wax,script,require=ImportGlobals(11)local ImportGlobals return (function(...)-- This codegen template *must* be 100% compatible with Lua 5.1x+, NOT just Luau
-- With that being said, this explains the weird cflow in some parts lol

return [[
-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = ${ClosureBindings} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = ${ObjectTree}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = ${LineOffsets}

-- Misc AOT variable imports
local WaxVersion = "${Version}"
local EnvName = "${EnvName}"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, newproxy, getmetatable, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, newproxy, getmetatable, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, recursive)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = newproxy(true)
    local RefMetatable = getmetatable(Ref)

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "userdata" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == ".." then
                    RealIndex = "Parent"
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end

-- If there's a "MainModule" top-level modulescript, we'll return it from the output's closure directly
do
    local MainModule
    local RealObjectRootChildren = RealObjectRoot:GetChildren()

    -- Doesn't need to be named "MainModule" if there's just 1 root obj and it's a ModuleScript
    if #RealObjectRootChildren == 1 and RealObjectRootChildren[1].ClassName == "ModuleScript" then
        MainModule = RealObjectRootChildren[1]
    else
        for _, Ref in next, RealObjectRootChildren do
            if Ref.ClassName == "ModuleScript" and Ref.Name == "MainModule" then
                MainModule = Ref
                break
            end
        end
    end

    if MainModule then
        return LoadScript(MainModule)
    end
end
]]

end)() end,
    [12] = function()local wax,script,require=ImportGlobals(12)local ImportGlobals return (function(...)return "0.3.6"

end)() end,
    [14] = function()local wax,script,require=ImportGlobals(14)local ImportGlobals return (function(...)-- LuaEncode - Optimal Table Serialization for Native Luau/Lua 5.1+
-- Copyright (c) 2022-2023 Reggie <reggie@latte.to> | MIT License
-- https://github.com/regginator/LuaEncode

--!nocheck
--!optimize 2

-- Localizing certain libraries/variables used throughout for runtime efficiency (not specific to Luau)
local table, ipairs, string, next, pcall, game, workspace, tostring, tonumber, getmetatable = table, ipairs, string, next, pcall, game, workspace, tostring, tonumber, getmetatable

local string_format = string.format
local string_char = string.char
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep
local string_sub = string.sub
local string_gmatch = string.gmatch

local table_find = table.find
local table_concat = table.concat
local table_insert = table.insert

-- For custom Roblox engine data-type support via `typeof`, if it exists
local Type = typeof or type

-- Used for checking direct getfield syntax; Lua keywords can't be used as keys without being a str
-- FYI; `continue` is Luau only (in Lua it's actually a global function), but we're including it
-- here anyway to be safe
local LuaKeywords do
    local LuaKeywordsArray = {
        "and", "break", "do", "else",
        "elseif", "end", "false", "for",
        "function", "if", "in", "local",
        "nil", "not", "or", "repeat",
        "return", "then", "true", "until",
        "while", "continue"
    }

    -- We're now setting each keyword str to a weak key, so it's faster at runtime for `SerializeString()`
    LuaKeywords = setmetatable({}, {__mode = "k"})

    for _, Keyword in next, LuaKeywordsArray do
        LuaKeywords[Keyword] = true
    end
end

-- Lua 5.1 doesn't have table.find
table_find = table_find or function(inputTable, valueToFind) -- Ignoring the `init` arg, unneeded for us
    for Key, Value in ipairs(inputTable) do
        if Value == valueToFind then
            return Key -- Return the key idx
        end
    end

    return
end

-- Simple function for directly checking the type on values, with their input, variable name,
-- and desired type name(s) to check
local function CheckType(inputData, dataName, ...)
    local DesiredTypes = {...}
    local InputDataType = Type(inputData)

    if not table_find(DesiredTypes, InputDataType) then
        error(string_format(
            "LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`",
            dataName,
            table_concat(DesiredTypes, ", "), -- For if multiple types are accepted
            InputDataType
        ), 0)
    end

    return inputData -- Return back input directly
end

-- This re-serializes a string back into Lua, for the interpreter AND humans to read. This fixes
-- `string_format("%q")` only outputting in system encoding, instead of explicit Lua byte escapes
local SerializeString do
    -- These are control characters to be encoded in a certain way in Lua rather than just a byte
    -- escape (e.g. "\n" -> "\10")
    local SpecialCharacters = {
        ["\""] = "\\\"", -- Double-Quote
        ["\\"] = "\\\\", -- (Literal) Backslash
        -- Special ASCII control char codes
        ["\a"] = "\\a", -- Bell; ASCII #7
        ["\b"] = "\\b", -- Backspace; ASCII #8
        ["\t"] = "\\t", -- Horizontal-Tab; ASCII #9
        ["\n"] = "\\n", -- Newline; ASCII #10
        ["\v"] = "\\v", -- Vertical-Tab; ASCII #11
        ["\f"] = "\\f", -- Form-Feed; ASCII #12
        ["\r"] = "\\r", -- Carriage-Return; ASCII #13
    }

    -- We need to assign all extra normal byte escapes for runtime optimization
    for Index = 0, 255 do
        local Character = string_char(Index)

        if not SpecialCharacters[Character] and (Index < 32 or Index > 126) then
            SpecialCharacters[Character] = "\\" .. Index
        end
    end

    function SerializeString(inputString)
        -- FYI; We can't do "\0-\31" in Lua 5.1 (Only Luau/Lua 5.2+) due to an embedded zeros in pattern
        -- issue. See: https://stackoverflow.com/a/22962409
        return "\"" .. string_gsub(inputString, "[%z\\\"\1-\31\127-\255]", SpecialCharacters) .. "\""
    end
end

-- We need to occasionally construct valid comment blocks from external input, with proper escapes etc
local function CommentBlock(inputString)
    local Padding = ""
    for Match in string_gmatch(inputString, "%](=*)%]") do
        if #Match >= #Padding then
            Padding = Match .. "="
        end
    end

    return "--[" .. Padding .. "[" .. inputString .. "]" .. Padding .. "]"
end

local EvaluateInstancePath do
    -- VERY simple function to get if an object is a service, used in instance path eval
    local function IsService(object)
        -- Logically, if an object is actually under a service, that service *has* to already exist, as we've
        -- presumably evaluated to said path
        local FindServiceSuccess, ServiceObject = pcall(game.FindService, game, object.ClassName)

        if FindServiceSuccess and ServiceObject then
            return true
        end

        return false
    end

    -- Evaluating an instances' accessable "path" with just it's ref, and if the root parent is nil/isn't
    -- under `game` or `workspace`, returns nil.
    function EvaluateInstancePath(object)
        -- "Recursive" eval
        local ObjectPointer = object

        -- Input itself doesn't exist?
        if not ObjectPointer then
            return
        end

        local Path = ""

        while ObjectPointer do
            local ObjectName = ObjectPointer.Name
            local ObjectClassName = ObjectPointer.ClassName
            local ObjectParent = ObjectPointer.Parent

            if ObjectParent == game and IsService(ObjectPointer) then
                -- ^^ Then we'll use GetService directly, since it's actually a service under the DataModel

                Path = ":GetService(" .. SerializeString(ObjectClassName) .. ")" .. Path
            elseif not LuaKeywords[ObjectName] and string_match(ObjectName, "^[A-Za-z_][A-Za-z0-9_]*$") then
                -- ^^ Like the `string` DataType, this means means we can index the name directly in Lua
                -- without an explicit string
                Path = "." .. ObjectName .. Path
            else
                Path = "[" .. SerializeString(ObjectName) .. "]" .. Path
            end

            if ObjectParent == game then
                Path = "game" .. Path
                return Path
            elseif ObjectParent == workspace then
                Path = "workspace" .. Path
                return Path
            end

            -- Advance ObjectPointer, whether it exists or not (JUMPBACK)
            ObjectPointer = ObjectParent
        end

        -- Fall back to no ret.. Only objects parented under game/workspace will be serialized
        return
    end
end

--[[
LuaEncode(inputTable: {[any]: any}, options: {[string]: any}): string

    ---------- OPTIONS: ----------

    Prettify <boolean?:false> | Whether or not the output should use pretty printing

    IndentCount <number?:0> | The amount of "spaces" that should be indented per entry (*Note:
    If `Prettify` is set to true and this is unspecified, it'll be set to `4` automatically*)

    OutputWarnings <boolean?:true> | If "warnings" should be placed to the output (as
    comments); It's recommended to keep this enabled, however this can be disabled at ease

    StackLimit <number?:500> | The limit to the stack level before recursive encoding cuts
    off, and stops execution. This is used to prevent stack overflow errors and such. You
    could use `math.huge` here if you really wanted

    FunctionsReturnRaw <boolean?:false> | If functions in said table return back a "raw"
    value to place in the output as the key/value

    UseInstancePaths <boolean?:true> | If `Instance` reference objects should return their
    Lua-accessable path for encoding. If the instance is parented under `nil` or isn't under
    `game`/`workspace`, it'll always fall back to `Instance.new(ClassName)` as before

    SerializeMathHuge <boolean?:true> | If numbers calculated as "infinite" (or negative-inf)
    numbers should be serialized with "math.huge". (uses the `math` import, as opposed to just
    a direct data type) If false, "`1/0`" or "`-1/0`" will be serialized, which is supported
    on all target versions

]]

local function LuaEncode(inputTable, options)
    -- Check all arg and option types
    CheckType(inputTable, "inputTable", "table") -- Required*, nil not allowed
    CheckType(options, "options", "table", "nil") -- `options` is an optional arg

    -- Options
    if options then
        CheckType(options.Prettify, "options.Prettify", "boolean", "nil")
        CheckType(options.PrettyPrinting, "options.PrettyPrinting", "boolean", "nil") -- Alias for `Options.Prettify`
        CheckType(options.IndentCount, "options.IndentCount", "number", "nil")
        CheckType(options.OutputWarnings, "options.OutputWarnings", "boolean", "nil")
        CheckType(options.StackLimit, "options.StackLimit", "number", "nil")
        CheckType(options.FunctionsReturnRaw, "options.FunctionsReturnRaw", "boolean", "nil")
        CheckType(options.UseInstancePaths, "options.UseInstancePaths", "boolean", "nil")
        CheckType(options.SerializeMathHuge, "options.SerializeMathHuge", "boolean", "nil")
        
        -- Internal options:
        CheckType(options._StackLevel, "options._StackLevel", "number", "nil")
        CheckType(options._VisitedTables, "options._StackLevel", "table", "nil")
    end

    options = options or {}

    -- Because no if-else-then exp. in Lua 5.1+ (only Luau), for optional boolean values we need to check
    -- if it's nil first, THEN fall back to whatever it's actually set to if it's not nil
    local Prettify = (options.Prettify == nil and options.PrettyPrinting == nil and false) or (options.Prettify ~= nil and options.Prettify) or (options.PrettyPrinting and options.PrettyPrinting)
    local IndentCount = options.IndentCount or (Prettify and 4) or 0
    local OutputWarnings = (options.OutputWarnings == nil and true) or options.OutputWarnings
    local StackLimit = options.StackLimit or 500
    local FunctionsReturnRaw = (options.FunctionsReturnRaw == nil and false) or options.FunctionsReturnRaw
    local UseInstancePaths = (options.UseInstancePaths == nil and true) or options.UseInstancePaths
    local SerializeMathHuge = (options.SerializeMathHuge == nil and true) or options.SerializeMathHuge

    -- Internal options:

    -- Internal stack level for depth checks and indenting
    local StackLevel = options._StackLevel or 1
    -- Set root as visited; cyclic detection
    local VisitedTables = options._VisitedTables or {[inputTable] = true} -- [`visitedTable <table>`] = `isVisited <boolean>`

    -- Stack overflow/output abuse etc; default StackLimit is 500
    if StackLevel >= StackLimit then
        return "{--[[LuaEncode: Stack level limit of `" .. StackLimit .. "` reached]]}"
    end

    -- For +/- inf num serialization
    local PositiveInf = (SerializeMathHuge and "math.huge") or "1/0"
    local NegativeInf = (SerializeMathHuge and "-math.huge") or "-1/0"

    -- Easy-to-reference values for specific args
    local NewEntryString = (Prettify and "\n") or ""
    local ValueSeperator = (Prettify and ", ") or ","
    local BlankSeperator = (Prettify and " ") or ""

    -- For pretty printing (which is optional, and false by default) we need to keep track
    -- of the current stack, then repeat IndentString by that count
    local IndentString = string_rep(" ", IndentCount) -- If 0 this will just be ""
    IndentString = (Prettify and string_rep(IndentString, StackLevel)) or IndentString

    local EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""

    -- For number key values, incrementing the current internal index
    local KeyIndex = 1

    -- Cases (C-Like) for encoding values, then end setup. Using cases so no elseif bs!
    -- Functions are all expected to return a (<string> EncodedKey, <boolean?> EncloseInBrackets)
    local TypeCases = {} do
        -- Basic func for getting the direct value of an encoded type without weird table.pack()[1] syntax
        local function TypeCase(typeName, value)
            -- Each of these funcs return a tuple, so it'd be annoying to do case-by-case
            local EncodedValue = TypeCases[typeName](value, false) -- False to label as NOT `isKey`
            return EncodedValue
        end

        -- For "tuple" args specifically, so there isn't a bunch of re-used code
        local function Args(...)
            local EncodedValues = {}

            for _, Arg in next, {...} do
                table_insert(EncodedValues, TypeCase(
                    Type(Arg),
                    Arg
                ))
            end

            return table_concat(EncodedValues, ValueSeperator)
        end

        -- For certain Roblox DataTypes, we use a custom serialization method for filling out params etc
        local function Params(newData, params)
            return "(function(v, p) for pn, pv in next, p do v[pn] = pv end return v end)(" ..
                table_concat({newData, TypeCase("table", params)}, ValueSeperator) ..
                ")"
        end

        TypeCases["number"] = function(value, isKey)
            -- If the number isn't the current real index of the table, we DO want to
            -- explicitly define it in the serialization no matter what for accuracy
            if isKey and value == KeyIndex then
                -- ^^ What's EXPECTED unless otherwise explicitly defined, if so, return no encoded num
                KeyIndex = KeyIndex + 1
                return nil, true
            end

            -- Lua's internal `tostring` handling will denote positive/negativie-infinite number TValues as "inf", which
            -- makes certain numbers not encode properly. We also just want to make the output precise
            if value == 1/0 then
                return PositiveInf
            elseif value == -1/0 then
                return NegativeInf
            end

            -- Return fixed-formatted precision num
            return string_format("%.14g", value)
        end

        TypeCases["string"] = function(value, isKey)
            if isKey and not LuaKeywords[value] and string_match(value, "^[A-Za-z_][A-Za-z0-9_]*$") then
                -- ^^ Then it's a syntaxically-correct variable, doesn't need explicit string def
                return value, true
            end

            return SerializeString(value)
        end

        TypeCases["table"] = function(value, isKey)
            -- Check duplicate/cyclic references
            do
                local VisitedTable = VisitedTables[value]
                if VisitedTable then
                    return string_format(
                        "{--[[LuaEncode: Duplicate reference%s]]}",
                        (value == inputTable and " (of parent)") or ""
                    )
                end

                VisitedTables[value] = true
            end

            -- *Point index not set by NewOptions to original
            local NewOptions = setmetatable({}, {__index = options}) do
                -- Overriding if key because it'd look worse pretty printed in a key
                NewOptions.Prettify = (isKey and false) or Prettify

                -- If Prettify is already false in the real args, set the indent to whatever
                -- the REAL IndentCount is set to
                NewOptions.IndentCount = (isKey and ((not Prettify and IndentCount) or 1)) or IndentCount

                -- Internal options
                NewOptions._StackLevel = (isKey and 1) or StackLevel + 1 -- If isKey, stack lvl is set to the **LOWEST** because it's the key to a value
                NewOptions._VisitedTables = VisitedTables
            end

            return LuaEncode(value, NewOptions)
        end

        TypeCases["boolean"] = function(value)
            return value and "true" or "false"
        end

        TypeCases["nil"] = function(value)
            return "nil"
        end

        TypeCases["function"] = function(value)
            -- If `FunctionsReturnRaw` is set as true, we'll call the function here itself, expecting
            -- a raw value for FunctionsReturnRaw to add as the key/value, you may want to do this for custom userdata or
            -- function closures. Thank's for listening to my Ted Talk!
            if FunctionsReturnRaw then
                return value()
            end

            -- If all else, force key func to return nil; can't handle a func val..
            return "function() --[[LuaEncode: `options.FunctionsReturnRaw` false; can't serialize functions]] return end"
        end

        ---------- ROBLOX CUSTOM DATATYPES BELOW ----------

        TypeCases["Axes"] = function(value)
            local EncodedArgs = {}
            local EnumValues = {
                ["Enum.Axis.X"] = value.X,
                ["Enum.Axis.Y"] = value.Y,
                ["Enum.Axis.Z"] = value.Z,
            }

            for EnumValue, IsEnabled in next, EnumValues do
                if IsEnabled then
                    table_insert(EncodedArgs, EnumValue)
                end
            end

            return "Axes.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
        end

        TypeCases["BrickColor"] = function(value)
            -- BrickColor.Number (Its enum ID) will be slightly more efficient in all cases in deser,
            -- so we'll use it if Options.Prettify is false
            return "BrickColor.new(" ..
                (Prettify and TypeCase("string", value.Name)) or value.Number ..
                ")"
        end

        TypeCases["CFrame"] = function(value)
            return "CFrame.new(" .. Args(value:components()) .. ")"
        end

        TypeCases["CatalogSearchParams"] = function(value)
            return Params("CatalogSearchParams.new()", {
                SearchKeyword = value.SearchKeyword,
                MinPrice = value.MinPrice,
                MaxPrice = value.MaxPrice,
                SortType = value.SortType, -- EnumItem
                CategoryFilter = value.CategoryFilter, -- EnumItem
                BundleTypes = value.BundleTypes, -- table
                AssetTypes = value.AssetTypes -- table
            })
        end

        TypeCases["Color3"] = function(value)
            -- Using floats for RGB values, most accurate for direct serialization
            return "Color3.new(" .. Args(value.R, value.G, value.B)
        end

        TypeCases["ColorSequence"] = function(value)
            return "ColorSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
        end

        TypeCases["ColorSequenceKeypoint"] = function(value)
            return "ColorSequenceKeypoint.new(" .. Args(value.Time, value.Value) .. ")"
        end

        -- We're using fromUnixTimestamp to serialize the object
        TypeCases["DateTime"] = function(value)
            -- Always an int, we don't need to do anything special
            return "DateTime.fromUnixTimestamp(" .. value.UnixTimestamp .. ")"
        end

        -- Properties seem to throw an error on index if the scope isn't a Studio plugin, so we're
        -- directly getting values! (so fun!!!!)
        TypeCases["DockWidgetPluginGuiInfo"] = function(value)
            -- e.g.: "InitialDockState:Right InitialEnabled:0 InitialEnabledShouldOverrideRestore:0 FloatingXSize:0 FloatingYSize:0 MinWidth:0 MinHeight:0"
            local ValueString = tostring(value)

            return "DockWidgetPluginGuiInfo.new(" ..
                Args(
                    -- InitialDockState (Enum.InitialDockState)
                    Enum.InitialDockState[string_match(ValueString, "InitialDockState:(%w+)")], -- Enum.InitialDockState.Right
                    -- InitialEnabled and InitialEnabledShouldOverrideRestore (boolean as number; `0` or `1`)
                    string_match(ValueString, "InitialEnabled:(%w+)") == "1", -- false
                    string_match(ValueString, "InitialEnabledShouldOverrideRestore:(%w+)") == "1", -- false
                    -- FloatingXSize/FloatingYSize (numbers)
                    tonumber(string_match(ValueString, "FloatingXSize:(%w+)")), -- 0
                    tonumber(string_match(ValueString, "FloatingYSize:(%w+)")), -- 0
                    -- MinWidth/MinHeight (numbers)
                    tonumber(string_match(ValueString, "MinWidth:(%w+)")), -- 0
                    tonumber(string_match(ValueString, "MinHeight:(%w+)")) -- 0
                ) ..
                ")"
        end

        -- e.g. `Enum.UserInputType`
        TypeCases["Enum"] = function(value)
            return "Enum." .. tostring(value) -- For now, this is the behavior of enums in tostring.. I have no other choice atm
        end

        -- e.g. `Enum.UserInputType.Gyro`
        TypeCases["EnumItem"] = function(value)
            return tostring(value) -- Returns the full enum index for now (e.g. "Enum.UserInputType.Gyro")
        end

        -- i.e. the `Enum` global return
        TypeCases["Enums"] = function(value)
            return "Enum"
        end

        TypeCases["Faces"] = function(value)
            local EncodedArgs = {}
            local EnumValues = {
                ["Enum.NormalId.Top"] = value.Top, -- These return bools
                ["Enum.NormalId.Bottom"] = value.Bottom,
                ["Enum.NormalId.Left"] = value.Left,
                ["Enum.NormalId.Right"] = value.Right,
                ["Enum.NormalId.Back"] = value.Back,
                ["Enum.NormalId.Front"] = value.Front,
            }

            for EnumValue, IsEnabled in next, EnumValues do
                if IsEnabled then
                    table_insert(EncodedArgs, EnumValue)
                end
            end

            return "Faces.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
        end

        TypeCases["FloatCurveKey"] = function(value)
            return "FloatCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
        end

        TypeCases["Font"] = function(value)
            return "Font.new(" .. Args(value.Family, value.Weight, value.Style) .. ")"
        end

        -- Instance refs can be evaluated to their paths (optional), but if parented to
        -- nil or some DataModel not under `game`, it'll just return nil
        TypeCases["Instance"] = function(value)
            if UseInstancePaths then
                local InstancePath = EvaluateInstancePath(value)
                if InstancePath then
                    return InstancePath
                end

                -- ^^ Now, if the path isn't accessable, falls back to the return below anyway
            end

            return "nil" .. BlankSeperator .. CommentBlock("Instance.new(" .. TypeCase("string", value.ClassName) .. ")")
        end

        TypeCases["NumberRange"] = function(value)
            return "NumberRange.new(" .. Args(value.Min, value.Max) .. ")"
        end

        TypeCases["NumberSequence"] = function(value)
            return "NumberSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
        end

        TypeCases["NumberSequenceKeypoint"] = function(value)
            return "NumberSequenceKeypoint.new(" .. Args(value.Time, value.Value, value.Envelope) .. ")"
        end

        TypeCases["OverlapParams"] = function(value)
            return Params("OverlapParams.new()", {
                FilterDescendantsInstances = value.FilterDescendantsInstances,
                FilterType = value.FilterType,
                MaxParts = value.MaxParts,
                CollisionGroup = value.CollisionGroup,
                RespectCanCollide = value.RespectCanCollide
            })
        end

        TypeCases["PathWaypoint"] = function(value)
            return "PathWaypoint.new(" .. Args(value.Position, value.Action, value.Label) .. ")"
        end

        TypeCases["PhysicalProperties"] = function(value)
            return "PhysicalProperties.new(" ..
                Args(
                    value.Density,
                    value.Friction,
                    value.Elasticity,
                    value.FrictionWeight,
                    value.ElasticityWeight
                ) ..
                ")"
        end

        TypeCases["Random"] = function()
            return "Random.new()"
        end

        TypeCases["Ray"] = function(value)
            return "Ray.new(" .. Args(value.Origin, value.Direction) .. ")"
        end

        TypeCases["RaycastParams"] = function(value)
            return Params("RaycastParams.new()", {
                FilterDescendantsInstances = value.FilterDescendantsInstances,
                FilterType = value.FilterType,
                IgnoreWater = value.IgnoreWater,
                CollisionGroup = value.CollisionGroup,
                RespectCanCollide = value.RespectCanCollide
            })
        end

        TypeCases["Rect"] = function(value)
            return "Rect.new(" .. Args(value.Min, value.Max) .. ")"
        end

        -- Roblox doesn't provide read properties for min/max on `Region3`, but they do on Region3int16.. Anyway,
        -- we CAN calculate the min/max of a Region3 from just .CFrame and .Size.. Thanks to wally for linking me
        -- the thread for this method lol
        TypeCases["Region3"] = function(value)
            local ValueCFrame = value.CFrame
            local ValueSize = value.Size

            return "Region3.new(" ..
                Args(
                    ValueCFrame * CFrame.new(-ValueSize / 2), -- Minimum
                    ValueCFrame * CFrame.new(ValueSize / 2) -- Maximum
                ) ..
                ")"
        end

        TypeCases["Region3int16"] = function(value)
            return "Region3int16.new(" .. Args(value.Min, value.Max) .. ")"
        end

        TypeCases["TweenInfo"] = function(value)
            return "TweenInfo.new(" ..
                Args(
                    value.Time,
                    value.EasingStyle,
                    value.EasingDirection,
                    value.RepeatCount,
                    value.Reverses,
                    value.DelayTime
                ) ..
                ")"
        end

        -- CURRENTLY UNDOCUMENTED*
        TypeCases["RotationCurveKey"] = function(value)
            return "RotationCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
        end

        TypeCases["UDim"] = function(value)
            return "UDim.new(" .. Args(value.Scale, value.Offset) .. ")"
        end

        TypeCases["UDim2"] = function(value)
            return "UDim2.new(" ..
                Args(
                    -- Not directly using X and Y UDims for better output (i.e. would be
                    -- UDim2.new(UDim.new(1, 0), UDim.new(1, 0)) if I did)
                    value.X.Scale,
                    value.X.Offset,
                    value.Y.Scale,
                    value.Y.Offset
                ) ..
                ")"
        end

        TypeCases["Vector2"] = function(value)
            return "Vector2.new(" .. Args(value.X, value.Y) .. ")"
        end

        TypeCases["Vector2int16"] = function(value)
            return "Vector2int16.new(" .. Args(value.X, value.Y) .. ")"
        end

        TypeCases["Vector3"] = function(value)
            return "Vector3.new(" .. Args(value.X, value.Y, value.Z) .. ")"
        end

        TypeCases["Vector3int16"] = function(value)
            return "Vector3int16.new(" .. Args(value.X, value.Y, value.Z) .. ")"
        end

        -- With userdata, just encode directly
        TypeCases["userdata"] = function(value)
            if getmetatable(value) then -- Has mt
                return "newproxy(true)"
            else
                return "newproxy()" -- newproxy() defaults to false (no mt)
            end
        end
    end

    -- Setup output tbl
    local Output = ""

    for Key, Value in next, inputTable do
        local KeyType = Type(Key)
        local ValueType = Type(Value)

        if TypeCases[KeyType] and TypeCases[ValueType] then
            local EntryOutput = (Prettify and NewEntryString .. IndentString) or ""
            local ValueWasEncoded = false -- Keeping track of this for adding a "," to the EntryOutput if needed

            -- Go through and get key val
            local KeyEncodedSuccess, EncodedKeyOrError, DontEncloseInBrackets = pcall(TypeCases[KeyType], Key, true) -- The `true` represents if it's a key or not, here it is

            -- Ignoring 2nd arg (`DontEncloseInBrackets`) because this isn't the key
            local ValueEncodedSuccess, EncodedValueOrError = pcall(TypeCases[ValueType], Value, false) -- `false` because it's NOT the key, it's the value

            -- Im sorry for this logic chain here, I can't use `continue`/`continue()`.. :sob:
            -- Ignoring `if EncodedKeyOrError` because the key doesn't actually need to ALWAYS
            -- be explicitly encoded, like if it's a number of the current key index!
            if KeyEncodedSuccess and ValueEncodedSuccess and EncodedValueOrError then
                -- NOW we'll check for if the key was explicitly encoded, because we don't to stop
                -- the value from encoding, since we've already checked that and it *has* been
                local KeyValue = EncodedKeyOrError and ((DontEncloseInBrackets and EncodedKeyOrError) or string_format("[%s]", EncodedKeyOrError)) .. ((Prettify and " = ") or "=") or ""

                -- Encode key/value together, we've already checked if `EncodedValueOrError` was returned
                EntryOutput = EntryOutput .. KeyValue .. EncodedValueOrError
                ValueWasEncoded = true
            elseif OutputWarnings then -- Then `Encoded(Key/Value)OrError` is the error msg
                -- ^^ Then either the key or value wasn't properly checked or encoded, and there
                -- was an error we need to log!
                local ErrorMessage = string_format(
                    "LuaEncode: Failed to encode %s of DataType `%s`: %s",
                    (not KeyEncodedSuccess and "key") or (not ValueEncodedSuccess and "value") or "key/value", -- "key/value" for bool type fallback
                    ValueType,
                    (not KeyEncodedSuccess and SerializeString(EncodedKeyOrError)) or (not ValueEncodedSuccess and SerializeString(EncodedValueOrError)) or "(Failed to get error message)"
                )

                EntryOutput = EntryOutput .. CommentBlock(ErrorMessage)
            end

            -- If there isn't another value after the current index, add ending formatting
            if next(inputTable, Key) then
                -- Yes.. The nesting here is deliberate
                if ValueWasEncoded then
                    EntryOutput = EntryOutput .. ","
                end
            else
                -- If there isn't another value after the current index, add ending formatting
                EntryOutput = EntryOutput .. NewEntryString .. EndingIndentString
            end

            Output = Output .. EntryOutput
        end
    end

    Output = "{" .. Output .. "}"
    return Output
end

return LuaEncode

end)() end
} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        2,
        {
            "Wax"
        },
        {
            {
                2,
                1,
                {
                    "lib"
                },
                {
                    {
                        13,
                        1,
                        {
                            "libraries"
                        },
                        {
                            {
                                14,
                                2,
                                {
                                    "LuaEncode"
                                }
                            }
                        }
                    },
                    {
                        9,
                        1,
                        {
                            "data"
                        },
                        {
                            {
                                10,
                                2,
                                {
                                    "DefaultDarkluaConfig"
                                }
                            },
                            {
                                11,
                                2,
                                {
                                    "Template"
                                }
                            },
                            {
                                12,
                                2,
                                {
                                    "Version"
                                }
                            }
                        }
                    },
                    {
                        4,
                        2,
                        {
                            "CommandUtils"
                        }
                    },
                    {
                        6,
                        2,
                        {
                            "ParseArgs"
                        }
                    },
                    {
                        7,
                        2,
                        {
                            "Run"
                        }
                    },
                    {
                        8,
                        2,
                        {
                            "StringUtils"
                        }
                    },
                    {
                        3,
                        2,
                        {
                            "BundleModel"
                        }
                    },
                    {
                        5,
                        2,
                        {
                            "Log"
                        }
                    }
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    20,
    [3] = 482,
    [4] = 705,
    [5] = 732,
    [6] = 769,
    [7] = 844,
    [8] = 877,
    [10] = 978,
    [11] = 1004,
    [12] = 1534,
    [14] = 1537
}

-- Misc AOT variable imports
local WaxVersion = "0.3.6"
local EnvName = "WaxRuntime"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, newproxy, getmetatable, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, newproxy, getmetatable, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, recursive)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = newproxy(true)
    local RefMetatable = getmetatable(Ref)

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "userdata" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == ".." then
                    RealIndex = "Parent"
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end

-- If there's a "MainModule" top-level modulescript, we'll return it from the output's closure directly
do
    local MainModule
    local RealObjectRootChildren = RealObjectRoot:GetChildren()

    -- Doesn't need to be named "MainModule" if there's just 1 root obj and it's a ModuleScript
    if #RealObjectRootChildren == 1 and RealObjectRootChildren[1].ClassName == "ModuleScript" then
        MainModule = RealObjectRootChildren[1]
    else
        for _, Ref in next, RealObjectRootChildren do
            if Ref.ClassName == "ModuleScript" and Ref.Name == "MainModule" then
                MainModule = Ref
                break
            end
        end
    end

    if MainModule then
        return LoadScript(MainModule)
    end
end
