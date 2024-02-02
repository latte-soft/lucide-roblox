--!nolint
--!nocheck
--!native
--!optimize 2

--[[
    Wax - A Fast Runtime Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics
    MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

    Wax Version: 0.4.0
]]

------------------------------------------------------------------------------------------------------

local a local aa,ab,ac,ad,ae,af,ag,ah,ai,aj,ak,al,am,b,c,d,e,f,g,h,i,j={function()local b,c,d=a(1)local e return(
function(...)if string.sub(_VERSION,1,4)~='Lune'then print
[[!! Wax doesn't appear to be running on Lune (https://lune-org.github.io/docs), which this script requires, exitting..]]
return end do local f,g,h,i,j,k=0,8,0,string.match(_VERSION,'Lune (%d+).(%d+).(%d+)')i,j,k=tonumber(i),tonumber(j),
tonumber(k)if not i then print(`! Can't parse Lune's version on the assumed format from "{_VERSION}", continuing anyway..\n`
)else _G.LuneVersion=`{i}.{j}.{k}`if i<f or(j<g and i<=f)or(k<h and j<=g and i<=f)then print(`! Lune version "{_G.
LuneVersion}" detected, but Wax currently recommends Lune {f}.{g}.{h} or higher, continuing anyway..\n`)end end end
local f,g,h,i,j,k,l,m,n=d'@lune/fs',d'@lune/serde',d'@lune/stdio',d'@lune/roblox',d'@lune/process',d
'lib/libraries/LuneUtils',d'lib/BundleModel',d'lib/data/Version',d'lib/data/DefaultDarkluaConfig'local o,p,q,r,s,t,u=k.
Log,k.StringUtils,k.CommandUtils,k.Run,k.ParseArgs,`Wax {m}\n`..
[[A Fast Runtime Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics

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
,'Run `lune wax help` for more info'h.write(h.color'reset'..h.style'reset')local function v(w:string):string return if j
.os=='windows'then w else'"'..p.SerializeStringData(w)..'"'end local w=table.clone(j.args)local x=table.remove(w,1)if
not x then print(t)return end x=string.lower(x)if x=='help'then print(t)return elseif x=='version'then print(`Wax v{m}`)
return elseif x=='bundle'then local y=s(w,{input={'string','default.project.json'},output={'string',nil},minify={
'boolean',false},['env-name']={'string',nil},['darklua-config-path']={'string',nil},['temp-dir-base']={'string',nil},[
'extra-offset-lines']={'number',0},['ci-mode']={'boolean',false},verbose={'boolean',true}},t)local z,A,B,C=y.verbose,y[
'ci-mode'],y.minify,y['env-name']local function D(E,...)if z then E(...)end end local function E(F:string,G:string)D(o.
Info,`Writing to "{F}"..`)f.writeFile(F,G)end local function F(G:string)D(o.Info,`Deleting file at "{G}"..`)f.
removeFile(G)end local function G(H:string)D(o.Info,`Creating directory at "{H}"..`)f.writeDir(H)end local function H(I:
string)D(o.Info,`Removing directory at "{I}"..`)f.removeDir(I)end local I=y.input if not f.isFile(I)then o.Error(`Failed to find file path "{
I}" from \`input\` option\n`)print(u)j.exit(1)end local J,K=p.DirectoryOfFilePath(I)or'',string.lower(I)local L=if
string.sub(K,-5)=='.rbxm'then'.rbxm'elseif string.sub(K,-6)=='.rbxmx'then'.rbxmx'elseif string.sub(K,-13)==
'.project.json'then'.project.json'else nil if not L then o.Error(`Invalid file type ".{p.FileType(I)}" for \`input\`, expected [".rbxm", ".rbxmx", ".project.json"]\n`
)print(u)j.exit(1)end local M=y.output if not M then local N if L=='.project.json'then local O,P=pcall(g.decode,'json'::
'json',f.readFile(I))if not O then o.Error(`Failed to parse Rojo project file at "{I}": {P}`)j.exit(1)end if not P.name
or type(P.name)~='string'then o.Warn(`Couldn't find proper "name" entry at the root of Rojo project file at "{I}", using its file name base instead..`
)else N=P.name end end if not N then N=p.FilePathWithoutExtension(I,false)end if not N then o.InternalError(`Failed to get file path without the extension for "{
M}"`)j.exit(1)end N..='.wax.lua'M=J..N else local N,O=p.FileType(M),p.DirectoryOfFilePath(M)if not O then o.Error(`\`output\` file path given, "{
M}" not a valid path\n`)print(u)j.exit(1)elseif not f.isDir(O)then o.Error(`Directory of \`output\` file path given, "{O
}" not found/invalid\n`)print(u)j.exit(1)elseif not N or not table.find({'lua','luau'},N)then local P=if N==''then
'<empty>'else'.'..N o.Error(`File type of \`output\` ({P}) invalid, expected [".lua", ".luau"]\n`)print(u)j.exit(1)end
end local N=p.FileNameFromPath(M)if not N then o.InternalError(`Failed to parse file name from output file path "{M}"`)j
.exit(1)end local O=p.FileNameWithoutExtension(N,false)if not O then o.InternalError(`Failed to parse file name without its extension from "{
N}"`)j.exit(1)end DarkluaConfigPath=y['darklua-config-path']if DarkluaConfigPath and not f.isFile(DarkluaConfigPath)then
o.Error(`File path given for \`darklua-config-path\`, "{DarkluaConfigPath}" not found`)j.exit(1)end local P=y[
'temp-dir-base']if not P then P=p.DirectoryOfFilePath(M)elseif not f.isDir(P)then o.Error(`\`temp-dir-base\` directory given, "{
P}" not found/invalid\n`)print(u)j.exit(1)end if not string.match(P,'[/\\]$')then P..='/'end local Q=P..'.wax-tmp/'if f.
isDir(Q)then D(o.Info,`Old .wax-tmp dir at "{Q}" already exists, removing..`)f.removeDir(Q)end ExtraOffsetLines=y[
'extra-offset-lines']if ExtraOffsetLines<0 then o.Error(`Option \`extra-offset-lines\` ({ExtraOffsetLines}) cannot be less than 0\n`
)print(u)j.exit(1)end if not B and ExtraOffsetLines>0 then D(o.Info,`(Note) Runtime line debugging *will* display with the assumption that \`{
ExtraOffsetLines}\` lines will be added to the output by you manually; make sure this is EXACT, as debugging info could be inaccurate otherwise`
)end local function R(S:string?)if S then o.Error(S)end if f.isDir(Q)then H(Q)end j.exit(1)end if L=='.project.json'and
not q.CommandExists'rojo'then o.Error(`Rojo project file given for input ("{I}"), but the \`rojo\` command wasn't found in your PATH environment variable..\n`
)print(u)j.exit(1)end local S=q.CommandExists'darklua'if B and not S then o.Warn
[[The `minify` option is set as true, but the `darklua` command wasn't found in your PATH environment variable.. (Wax won't be able to completely minify the output)]]
if not A then local T=h.prompt('confirm','Continue anyway?')if not T then R()end end end if L=='.project.json'or(B and S
)then G(Q)end local T if table.find({'.rbxm','.rbxmx'},L)then D(o.Info,`Deserializing Roblox model file at "{I}"..`)
local U,V=pcall(i.deserializeModel,f.readFile(I))if not U then R(`Failed to deserialize Roblox model file at "{I}": {V}`
)end T=V elseif L=='.project.json'then local U=Q..O..'.o.rbxm'D(o.Info,`Building from Rojo project file to "{U}"`)r(
'rojo',{'build','-o',v(U),v(I)},false,R)T=i.deserializeModel(f.readFile(U))F(U)end local U,V,W=pcall(l,T,C,B,
ExtraOffsetLines,z)if not U then R(`Error during BundleModel() process: {V}`)end if B and S then local X=Q..N E(X,V)D(o.
Info,'Starting minification process with Darklua')local Y,Z,_={},Q..'.darklua.json',false if DarkluaConfigPath then
table.insert(Y,`-c={v(DarkluaConfigPath)}`)elseif not f.isFile'.darklua.json'and not f.isFile'.darklua.json5'then D(o.
Info,`No default Darklua config file found in CWD; creating our default config at "{Z}"`)E(Z,n)_=true table.insert(Y,`-c={
v(Z)}`)end r('darklua',{'process',v(X),v(M),unpack(Y)})F(X)if _ then F(Z)end else E(M,V)end if f.isDir(Q)then H(Q)end if
W>0 then print()o.Warn(`WARNING: {W} scripts failed to compile ahead-of-time (CHECK FULL BUILD LOG ABOVE FOR MORE DETAILS); these will throw errors at runtime upon being loaded, detailing said compilation errors.`
)j.exit(1)end else o.Error(`Subcommand "{x}" invalid, see usage for all valid subcommands:\n`)print(t)j.exit(1)end end)(
)end,[3]=function()local b,c,d=a(3)local e return(function(...)local f,g,h=d'@lune/luau',d'@lune/roblox',d
'libraries/LuneUtils'local i,j,k,l,m,n=h.Log,h.StringUtils,d'libraries/LuaEncode',d'data/Version',d'data/Template',{
Folder=1,ModuleScript=2,Script=3,LocalScript=4,StringValue=5}local function o(p:string|{roblox.Instance},q:string?,r:
boolean?,s:number?,t:boolean?):(string,number)local u,v,w,x=q or'WaxRuntime',if r==nil then true else r,s or 0,if t==nil
then true else t local function y(z,...)if x then z(...)end end local z,A,B,C,D,E,F,G,H=v==false,if type(p)=='string'
then g.deserializeModel(p)else p,os.clock(),0,{},{},{},{},{}local function I(J)table.insert(H,J)local K={}for L,M in J:
GetChildren()do K[M]=I(M)end return K end local J=A for K,L in J do G[L]=I(L)end local function M(N,O,P:string?)P=P or N
.Name local Q,R=table.find(H,N),N.ClassName local S=n[R]if not S then i.Warn(`Skipping instance of ClassName "{R}", as it isn't supported in bundling`
)return end local T=R=='LocalScript'or R=='Script'local U,V=T or R=='ModuleScript',{[1]=Q,[2]=S}if U and not(T and N.
Disabled)then local W=N.Source y(i.Info,`Compile-checking {N.ClassName} "{P}"..`)local X,Y=pcall(f.compile,W)if X then F
[Q]=j.LineCount(W)+1 E[Q]=function()return'function()local wax,script,require=ImportGlobals('..Q..
')local ImportGlobals return (function(...)'..W..'\nend)() end'end else local Z=string.match(tostring(Y),
'%w* ?:%d*: ?([^\n]*)\n')i.Warn(`WARNING: {N.ClassName} "{P}" failed to compile: {Z or'[Failed to parse compiler error]'
}`)C+=1 F[Q]=1 E[Q]=function()return`function()error("[AOT COMPILER ERROR] {j.SerializeStringData(Z)}")end`end end end
local W={[1]=N.Name}if R=='StringValue'then W.Value=N.Value end if N.Name~=R then V[3]=W end if next(O)then local X={}
for Y,Z in O do local _=M(Y,Z,`{P}.{Y.Name}`)if _ then table.insert(X,_)end end V[4]=X end return V end for N,O in G do
local P=M(N,O)if P then table.insert(D,P)end end local P={}if z then local Q=w+8 for R,S in F do P[R]=Q Q+=S end end
local Q=os.clock()y(i.Info,`Finished bundling model data in {string.format('%.4f',Q-B)} (seconds)`)local R=if v==false
then true else false local S,T,U=k(D,{Prettify=R,StackLimit=math.huge}),k(E,{Prettify=R,FunctionsReturnRaw=true}),if not
z then'nil'else k(P,{Prettify=R})local V=j.Replace(m,{Version=j.SerializeStringData(l),EnvName=j.SerializeStringData(u),
ObjectTree=S,ClosureBindings=T,LineOffsets=U})if#J==1 and J[1].ClassName=='ModuleScript'then V..=
[[

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot:GetChildren()[1])]]else
for W,X in next,J do if X.ClassName=='ModuleScript'and X.Name=='MainModule'then V..=
[[

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot.MainModule)]]break end
end end return V,C end return o end)()end,[5]=function()local b,c,d=a(5)local e return(function(...)local f,g=d
'@lune/serde',{generator={name='dense',column_span=120},rules={'convert_index_to_field','compute_expression',
'group_local_assignment','filter_after_early_return','remove_comments','remove_empty_do','remove_function_call_parens',
'remove_nil_declaration','remove_method_definition','remove_spaces','remove_unused_if_branch','remove_unused_while',{
rule='rename_variables',include_functions=true}}}return f.encode('json',g,false)end)()end,[6]=function()local b,c,d=a(6)
local e return(function(...)return
[[-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

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
                return Child:FindFirstChild(name, true)
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
]]
end)()end,[7]=function()local b,c,d=a(7)local e return(function(...)return'0.4.0'end)()end,[9]=function()local b,c,d=a(9
)local e return(function(...)local f,g,h,i,j,k,l,m,n,o=table,ipairs,string,next,pcall,game,workspace,tostring,tonumber,
getmetatable local p,q,r,s,t,u,v,w,x,y,z,A=h.format,h.char,h.gsub,h.match,h.rep,h.sub,h.gmatch,f.find,f.concat,f.insert,
(typeof or type)do local B={'and','break','do','else','elseif','end','false','for','function','if','in','local','nil',
'not','or','repeat','return','then','true','until','while','continue'}A=setmetatable({},{__mode='k'})for C,D in i,B do A
[D]=true end end w=w or function(B,C)for D,E in g(B)do if E==C then return D end end return end local function B(C,D,...
)local E,F={...},z(C)if not w(E,F)then error(p('LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`',D,x(E,', ')
,F),0)end return C end local C do local D={['"']='\\"',['\\']='\\\\',['\a']='\\a',['\b']='\\b',['\t']='\\t',['\n']='\\n'
,['\v']='\\v',['\f']='\\f',['\r']='\\r'}for E=0,255 do local F=q(E)if not D[F]and(E<32 or E>126)then D[F]='\\'..E end
end function C(E)return'"'..r(E,'[%z\\"\1-\31\127-\255]',D)..'"'end end local function D(E)local F=''for G in v(E,
'%](=*)%]')do if#G>=#F then F=G..'='end end return'--['..F..'['..E..']'..F..']'end local E do local function F(G)local H
,I=j(k.FindService,k,G.ClassName)if H and I then return true end return false end function E(G)local H=G if not H then
return end local I=''while H do local J,K,M=H.Name,H.ClassName,H.Parent if M==k and F(H)then I=':GetService('..C(K)..')'
..I elseif not A[J]and s(J,'^[A-Za-z_][A-Za-z0-9_]*$')then I='.'..J..I else I='['..C(J)..']'..I end if M==k then I=
'game'..I return I elseif M==l then I='workspace'..I return I end H=M end return end end local function F(G,H)B(G,
'inputTable','table')B(H,'options','table','nil')if H then B(H.Prettify,'options.Prettify','boolean','nil')B(H.
PrettyPrinting,'options.PrettyPrinting','boolean','nil')B(H.IndentCount,'options.IndentCount','number','nil')B(H.
OutputWarnings,'options.OutputWarnings','boolean','nil')B(H.StackLimit,'options.StackLimit','number','nil')B(H.
FunctionsReturnRaw,'options.FunctionsReturnRaw','boolean','nil')B(H.UseInstancePaths,'options.UseInstancePaths',
'boolean','nil')B(H.SerializeMathHuge,'options.SerializeMathHuge','boolean','nil')B(H._StackLevel,'options._StackLevel',
'number','nil')B(H._VisitedTables,'options._StackLevel','table','nil')end H=H or{}local I=(H.Prettify==nil and H.
PrettyPrinting==nil and false)or(H.Prettify~=nil and H.Prettify)or(H.PrettyPrinting and H.PrettyPrinting)local J,K,M,N,O
,P,Q,R=H.IndentCount or(I and 4)or 0,(H.OutputWarnings==nil and true)or H.OutputWarnings,H.StackLimit or 500,(H.
FunctionsReturnRaw==nil and false)or H.FunctionsReturnRaw,(H.UseInstancePaths==nil and true)or H.UseInstancePaths,(H.
SerializeMathHuge==nil and true)or H.SerializeMathHuge,H._StackLevel or 1,H._VisitedTables or{[G]=true}if Q>=M then
return'{--[[LuaEncode: Stack level limit of `'..M..'` reached]]}'end local S,T,U,V,W,X=(P and'math.huge')or'1/0',(P and
'-math.huge')or'-1/0',(I and'\n')or'',(I and', ')or',',(I and' ')or'',t(' ',J)X=(I and t(X,Q))or X local Y,Z,_=(#X>0 and
u(X,1,-J-1))or'',1,{}do local function aa(ab,ac)local ad=_[ab](ac,false)return ad end local function ab(...)local ac={}
for ad,ae in i,{...}do y(ac,aa(z(ae),ae))end return x(ac,V)end local function ac(ad,ae)return
[[(function(v, p) for pn, pv in next, p do v[pn] = pv end return v end)(]]..x({ad,aa('table',ae)},V)..')'end _.number=
function(ad,ae)if ae and ad==Z then Z=Z+1 return nil,true end if ad==1/0 then return S elseif ad==-1/0 then return T end
return p('%.14g',ad)end _.string=function(ad,ae)if ae and not A[ad]and s(ad,'^[A-Za-z_][A-Za-z0-9_]*$')then return ad,
true end return C(ad)end _.table=function(ad,ae)do local af=R[ad]if af then return p(
'{--[[LuaEncode: Duplicate reference%s]]}',(ad==G and' (of parent)')or'')end R[ad]=true end local af=setmetatable({},{
__index=H})do af.Prettify=(ae and false)or I af.IndentCount=(ae and((not I and J)or 1))or J af._StackLevel=(ae and 1)or
Q+1 af._VisitedTables=R end return F(ad,af)end _.boolean=function(ad)return ad and'true'or'false'end _['nil']=function(
ad)return'nil'end _['function']=function(ad)if N then return ad()end return
[=[function() --[[LuaEncode: `options.FunctionsReturnRaw` false; can't serialize functions]] return end]=]end _.Axes=
function(ad)local ae,af={},{['Enum.Axis.X']=ad.X,['Enum.Axis.Y']=ad.Y,['Enum.Axis.Z']=ad.Z}for ag,ah in i,af do if ah
then y(ae,ag)end end return'Axes.new('..x(ae,V)..')'end _.BrickColor=function(ad)return'BrickColor.new('..(I and aa(
'string',ad.Name))or ad.Number..')'end _.CFrame=function(ad)return'CFrame.new('..ab(ad:components())..')'end _.
CatalogSearchParams=function(ad)return ac('CatalogSearchParams.new()',{SearchKeyword=ad.SearchKeyword,MinPrice=ad.
MinPrice,MaxPrice=ad.MaxPrice,SortType=ad.SortType,CategoryFilter=ad.CategoryFilter,BundleTypes=ad.BundleTypes,
AssetTypes=ad.AssetTypes})end _.Color3=function(ad)return'Color3.new('..ab(ad.R,ad.G,ad.B)end _.ColorSequence=function(
ad)return'ColorSequence.new('..aa('table',ad.Keypoints)..')'end _.ColorSequenceKeypoint=function(ad)return
'ColorSequenceKeypoint.new('..ab(ad.Time,ad.Value)..')'end _.DateTime=function(ad)return'DateTime.fromUnixTimestamp('..
ad.UnixTimestamp..')'end _.DockWidgetPluginGuiInfo=function(ad)local ae=m(ad)return'DockWidgetPluginGuiInfo.new('..ab(
Enum.InitialDockState[s(ae,'InitialDockState:(%w+)')],s(ae,'InitialEnabled:(%w+)')=='1',s(ae,
'InitialEnabledShouldOverrideRestore:(%w+)')=='1',n(s(ae,'FloatingXSize:(%w+)')),n(s(ae,'FloatingYSize:(%w+)')),n(s(ae,
'MinWidth:(%w+)')),n(s(ae,'MinHeight:(%w+)')))..')'end _.Enum=function(ad)return'Enum.'..m(ad)end _.EnumItem=function(ad
)return m(ad)end _.Enums=function(ad)return'Enum'end _.Faces=function(ad)local ae,af={},{['Enum.NormalId.Top']=ad.Top,[
'Enum.NormalId.Bottom']=ad.Bottom,['Enum.NormalId.Left']=ad.Left,['Enum.NormalId.Right']=ad.Right,['Enum.NormalId.Back']
=ad.Back,['Enum.NormalId.Front']=ad.Front}for ag,ah in i,af do if ah then y(ae,ag)end end return'Faces.new('..x(ae,V)..
')'end _.FloatCurveKey=function(ad)return'FloatCurveKey.new('..ab(ad.Time,ad.Value,ad.Interpolation)..')'end _.Font=
function(ad)return'Font.new('..ab(ad.Family,ad.Weight,ad.Style)..')'end _.Instance=function(ad)if O then local ae=E(ad)
if ae then return ae end end return'nil'..W..D('Instance.new('..aa('string',ad.ClassName)..')')end _.NumberRange=
function(ad)return'NumberRange.new('..ab(ad.Min,ad.Max)..')'end _.NumberSequence=function(ad)return'NumberSequence.new('
..aa('table',ad.Keypoints)..')'end _.NumberSequenceKeypoint=function(ad)return'NumberSequenceKeypoint.new('..ab(ad.Time,
ad.Value,ad.Envelope)..')'end _.OverlapParams=function(ad)return ac('OverlapParams.new()',{FilterDescendantsInstances=ad
.FilterDescendantsInstances,FilterType=ad.FilterType,MaxParts=ad.MaxParts,CollisionGroup=ad.CollisionGroup,
RespectCanCollide=ad.RespectCanCollide})end _.PathWaypoint=function(ad)return'PathWaypoint.new('..ab(ad.Position,ad.
Action,ad.Label)..')'end _.PhysicalProperties=function(ad)return'PhysicalProperties.new('..ab(ad.Density,ad.Friction,ad.
Elasticity,ad.FrictionWeight,ad.ElasticityWeight)..')'end _.Random=function()return'Random.new()'end _.Ray=function(ad)
return'Ray.new('..ab(ad.Origin,ad.Direction)..')'end _.RaycastParams=function(ad)return ac('RaycastParams.new()',{
FilterDescendantsInstances=ad.FilterDescendantsInstances,FilterType=ad.FilterType,IgnoreWater=ad.IgnoreWater,
CollisionGroup=ad.CollisionGroup,RespectCanCollide=ad.RespectCanCollide})end _.Rect=function(ad)return'Rect.new('..ab(ad
.Min,ad.Max)..')'end _.Region3=function(ad)local ae,af=ad.CFrame,ad.Size return'Region3.new('..ab(ae*CFrame.new(-af/2),
ae*CFrame.new(af/2))..')'end _.Region3int16=function(ad)return'Region3int16.new('..ab(ad.Min,ad.Max)..')'end _.TweenInfo
=function(ad)return'TweenInfo.new('..ab(ad.Time,ad.EasingStyle,ad.EasingDirection,ad.RepeatCount,ad.Reverses,ad.
DelayTime)..')'end _.RotationCurveKey=function(ad)return'RotationCurveKey.new('..ab(ad.Time,ad.Value,ad.Interpolation)..
')'end _.UDim=function(ad)return'UDim.new('..ab(ad.Scale,ad.Offset)..')'end _.UDim2=function(ad)return'UDim2.new('..ab(
ad.X.Scale,ad.X.Offset,ad.Y.Scale,ad.Y.Offset)..')'end _.Vector2=function(ad)return'Vector2.new('..ab(ad.X,ad.Y)..')'end
_.Vector2int16=function(ad)return'Vector2int16.new('..ab(ad.X,ad.Y)..')'end _.Vector3=function(ad)return'Vector3.new('..
ab(ad.X,ad.Y,ad.Z)..')'end _.Vector3int16=function(ad)return'Vector3int16.new('..ab(ad.X,ad.Y,ad.Z)..')'end _.userdata=
function(ad)if o(ad)then return'newproxy(true)'else return'newproxy()'end end end local aa=''for ab,ac in i,G do local
ad,ae=z(ab),z(ac)if _[ad]and _[ae]then local af,ag,ah,ai,aj=(I and U..X)or'',false,j(_[ad],ab,true)local ak,al=j(_[ae],
ac,false)if ah and ak and al then local am=ai and((aj and ai)or p('[%s]',ai))..((I and' = ')or'=')or''af=af..am..al ag=
true elseif K then local am=p('LuaEncode: Failed to encode %s of DataType `%s`: %s',(not ah and'key')or(not ak and
'value')or'key/value',ae,(not ah and C(ai))or(not ak and C(al))or'(Failed to get error message)')af=af..D(am)end if i(G,
ab)then if ag then af=af..','end else af=af..U..Y end aa=aa..af end end aa='{'..aa..'}'return aa end return F end)()end,
[10]=function()local aa,ab,ac=a(10)local ad return(function(...)return{Log=ac'Log',StringUtils=ac'StringUtils',
CommandUtils=ac'CommandUtils',WebhookQueue=ac'WebhookQueue',Run=ac'Run',ParseArgs=ac'ParseArgs',EnsureFileTree=ac
'EnsureFileTree',RecursiveReadDir=ac'RecursiveReadDir'}end)()end,[11]=function()local aa,ab,ac=a(11)local ad return(
function(...)local ae,af=ac'@lune/process',{}function af.CommandExists(ag:string):boolean if ae.os~='windows'then return
ae.spawn('type',{ag},{shell=true}).ok end return true end function af.CheckCommands(ag:{string})for ah,ai in ag do
assert(af.CommandExists(ai),`Required command "{ai}" no found in your PATH environment variable, is it not installed?`)
end end return af end)()end,[12]=function()local aa,ab,ac=a(12)local ad return(function(...)local ae=ac'@lune/fs'
local function af(ag:{[string]:any},ah:string?)for ai,aj in ag do local ak,al=if ah then`{ah}/{ai}`else ai,type(aj)if al
=='table'then if not ae.isDir(ak)then ae.writeDir(ak)end af(aj,ak)elseif al=='string'and not ae.isFile(ak)then ae.
writeFile(ak,aj)end end end return af end)()end,[13]=function()local aa,ab,ac=a(13)local ad return(function(...)local ae
=ac'@lune/stdio'local af,ag={Reset=ae.color'reset'..ae.style'reset',Red=ae.color'red',Yellow=ae.color'yellow',Bold=ae.
style'bold'},{}function ag.Info(ah:string,ai:string?)ai=ai or'\n'ae.write(`\u{2219} {ah}{ai}`)end function ag.Error(ah:
string,ai:string?)ai=ai or'\n'ae.ewrite(`{af.Bold..af.Red}\u{2219} {ah}{af.Reset}{ai}`)end function ag.Warn(ah:string,ai
:string?)ai=ai or'\n'ae.write(`{af.Bold..af.Yellow}\u{2219} {ah}{af.Reset}{ai}`)end function ag.InternalError(ah:string,
ai:string?)ag.Error('[INTERNAL ERROR] '..ah,ai)end return ag end)()end,[14]=function()local aa,ab,ac=a(14)local ad
return(function(...)type OptionsInput={[string]:{string|number|boolean|nil}}type OptionsOutput={[string]:string|number|
boolean|nil}local ae,af=ac'@lune/process',ac'Log'local function ag(ah:{string},ai:OptionsInput,aj:string?):OptionsOutput
local function ak()if aj then print(`\n{aj}`)end ae.exit(1)end local al={}for am,b in ah do local c,d=string.match(b,
'([%w%-_]+)=(.+)')if not c then af.Error(`Command argument given, "{b}" not in the proper \`option=value\` format, aborting..`
)ak()end local e=ai[c]if e==nil then af.Error(`"{c}" isn't a valid option"`)ak()end local f=e[1]if f=='boolean'then d=
string.lower(d)d=if d=='true'then true elseif d=='false'then false else nil if d==nil then af.Error(`"{d}" isn't a valid boolean type; expected "true" or "false"`
)ak()end elseif f=='number'then d=tonumber(d)if not d then af.Error(`Failed to convert given input "{d}" to a number value`
)ak()end end al[c]=d end for c,d in ai do local e,f=d[2],d[3]or false if not al[c]then if f then af.Error(`Option "{c}" required but not provided`
)ak()end al[c]=e end end return al end return ag end)()end,[15]=function()local aa,ab,ac=a(15)local ad return(function(
...)local ae=ac'@lune/fs'local function af(ag:string,ah:{string}?):{string}if not string.match(ag,'[/\\]$')then ag..='/'
end local ai=ah or{}for aj,ak in ae.readDir(ag)do if ae.isFile(ak)then table.insert(ai,ag..ak)else af(ag..ak..'/',ai)end
end return ai end return af end)()end,[16]=function()local aa,ab,ac=a(16)local ad return(function(...)local ae,af=ac
'@lune/process',ac'Log'local function ag(ah:string,ai:{string}?,aj:boolean?,ak:((string?)->())?):process.SpawnResult
local al,am=ai or{},if aj==nil then false else aj if not am then if#al==0 then af.Info(`> {ah}`)else af.Info(`> {ah} {
table.concat(al,' ')}`)end end local b=ae.spawn(ah,ai,{shell=if ae.os~='windows'then true else nil,stdio=if am then
'default'else'inherit'})if not b.ok and ak then ak(`Command above failed with status code {b.code}`)end return b end
return ag end)()end,[17]=function()local aa,ab,ac=a(17)local ad return(function(...)local ae={}function ae.FileType(af:
string):string?local ag=string.match(af,'.%.([^%.]+)$')if ag then ag=string.lower(ag)end return ag end function ae.
FileNameFromPath(af:string):string?return string.match(af,'[^/\\]+$')end function ae.FileNameWithoutExtension(af:string,
ag:boolean?):string?ag=if ag==nil then true else ag if ag then return string.match(af,'^(.+)%.')else return string.
match(af,'^%.?[^%.]+')end end function ae.FilePathWithoutExtension(af:string,ag:boolean?):string?local ah,ai=ae.
DirectoryOfFilePath(af),ae.FileNameFromPath(af)if not ah or not ai then return end local aj=ae.FileNameWithoutExtension(
ai,ag)if not aj then return end return ah..aj end function ae.DirectoryOfFilePath(af:string):string?local ag=string.
match(af,'^.*[/\\]')if not ag or ag==''then ag='./'end return ag end function ae.SplitStringByPattern(af:string,ag:
string)local ah={}for ai in string.gmatch(af,ag)do table.insert(ah,ai)end return ah end function ae.SplitFilePath(af:
string)return ae.SplitStringByPattern(af,'([^/\\]+)[/\\]?')end function ae.LineCount(af:string):number local ag=1 for ah
in string.gmatch(af,'\n')do ag+=1 end return ag end function ae.Replace(af:string,ag:{[string]:string}):string return
string.gsub(af,'${([A-Za-z_][A-Za-z0-9_]*)}',ag)end do local af={['"']='\\"',['\\']='\\\\',['\a']='\\a',['\b']='\\b',[
'\t']='\\t',['\n']='\\n',['\v']='\\v',['\f']='\\f',['\r']='\\r'}for ag=0,255 do local ah=string.char(ag)if not af[ah]and
(ag<32 or ag>126)then af[ah]='\\'..ag end end function ae.SerializeStringData(ag:string):string local ah=string.gsub(ag,
'[%z\\"\1-\31\127-\255]',af)return ah end end return ae end)()end,[18]=function()local aa,ab,ac=a(18)local ad return(
function(...)export type WebhookObject={[string]:any}local ae,af,ag,ah,ai=ac'@lune/net',ac'@lune/task',ac'@lune/serde',
false,{}local function aj(ak:number?)ak=ak or 3 if ah then return end ah=true af.spawn(function()while ah do repeat af.
wait()until#ai>=1 local al=ai[1]local am,b:WebhookObject=al[1],al[2]local c=ag.encode('json',b)local d=ae.request{url=am
,method='POST',headers={['Content-Type']='application/json'},body=c}if not d.ok then print(`[!] Error in webhook request ({
d.statusCode}): {d.body}\n[^^ Waiting 5 seconds..]`)af.wait(5)continue end print(`[*] Discord Response ({d.statusCode}): {
d.body}`)af.wait(ak)table.remove(ai,1)end end)end local function ak()ah=false end local function al(am:string,b:
WebhookObject)table.insert(ai,{[1]=am,[2]=b})end local function am()ai={}end local function b()repeat af.wait()until#ai
==0 end return{Start=aj,Stop=ak,Add=al,Clear=am,Await=b}end)()end},{{1,2,{'Wax'},{{2,1,{'lib'},{{3,2,{'BundleModel'}},{4
,1,{'data'},{{7,2,{'Version'}},{6,2,{'Template'}},{5,2,{'DefaultDarkluaConfig'}}}},{8,1,{'libraries'},{{10,2,{
'LuneUtils'},{{12,2,{'EnsureFileTree'}},{11,2,{'CommandUtils'}},{14,2,{'ParseArgs'}},{15,2,{'RecursiveReadDir'}},{13,2,{
'Log'}},{18,2,{'WebhookQueue'}},{16,2,{'Run'}},{17,2,{'StringUtils'}}}},{9,2,{'LuaEncode'}}}}}}}}},'0.4.0','WaxRuntime',
string,task,setmetatable,error,newproxy,getmetatable,next,table,unpack,coroutine,script,type,require,pcall,tostring,
tonumber,_VERSION local k,l,m,n,o,p,q=al.insert,al.remove,al.freeze or function(k)return k end,b.wrap,ae.sub,ae.match,ae
.gmatch if i and o(i,1,4)=='Lune'then local r,s=f(e,'@lune/task')if r and s then af=s end end local r=af and af.defer
local s,t,u,v,w,x,y,z,A=r or function(s,...)n(s)(...)end,{[1]='Folder',[2]='ModuleScript',[3]='Script',[4]='LocalScript'
,[5]='StringValue'},{},{},{},{},{},{},{}local B,C={GetFullName={{},function(B)local C,D=B.Name,B.Parent while D do C=D.
Name..'.'..C D=D.Parent end return C end},GetChildren={{},function(B)local C={}for D in ak,A[B]do k(C,D)end return C end
},GetDescendants={{},function(B)local C={}for D in ak,A[B]do k(C,D)for E,F in ak,D:GetDescendants()do k(C,F)end end
return C end},FindFirstChild={{'string','boolean?'},function(B,C,D)local E=A[B]for F in ak,E do if F.Name==C then return
F end end if D then for G in ak,E do return G:FindFirstChild(C,true)end end end},FindFirstAncestor={{'string'},function(
B,C)local D=B.Parent while D do if D.Name==C then return D end D=D.Parent end end},WaitForChild={{'string','number?'},
function(B,C)return B:FindFirstChild(C)end}},{}for D,E in ak,B do local F,G,H=E[1],E[2],{}for I,J in ak,F do local K,M=
p(J,'^([^%?]+)(%??)')H[I]={K,M}end C[D]=function(K,...)if not A[K]then ah(
"Expected ':' not '.' calling member function "..D,2)end local M={...}for N,O in ak,H do local P=M[N]local Q,R,S=d(P),O[
1],O[2]if P==nil and not S then ah('Argument '..P..' missing or nil',3)end if R~='any'and Q~=R and not(Q=='nil'and S)
then ah('Argument '..N..' expects type "'..R..'", got "'..Q..'"',2)end end return G(K,...)end end local function F(G,H,I
)local J,K=(ag({},{__mode='k'}))local function M(N)ah(N..' is not a valid (virtual) member of '..G..' "'..H..'"',3)end
local function N(O)ah('Unable to assign (virtual) property '..O..'. Property is read only',3)end local O=ai(true)local P
=aj(O)P.__metatable=false P.__index=function(Q,R)if R=='ClassName'then return G elseif R=='Name'then return H elseif R==
'Parent'then return I elseif G=='StringValue'and R=='Value'then return K else local S=C[R]if S then return S end end for
S in ak,J do if S.Name==R then return S end end M(R)end P.__newindex=function(Q,R,S)if R=='ClassName'then N(R)elseif R==
'Name'then H=S elseif R=='Parent'then if S==O then return end if I~=nil then A[I][O]=nil end I=S if S~=nil then A[S][O]=
true end elseif G=='StringValue'and R=='Value'then K=S else M(R)end end P.__tostring=function()return H end A[O]=J if I
~=nil then A[I][O]=true end return O end local function G(H,I)local J,K,M,N=H[1],H[2],H[3],H[4]local O=t[K]local P=M and
l(M,1)or O local Q=F(O,P,I)u[J]=Q if M then for R,S in ak,M do Q[R]=S end end if N then for R,S in ak,N do G(S,Q)end end
return Q end local H=F('Folder','['..ad..']')for I,J in ak,ab do G(J,H)end for K,M in ak,aa do local N=u[K]v[N]=M w[N]=K
local O=N.ClassName if O=='LocalScript'or O=='Script'then k(y,N)end end local function N(O)local P,Q=O.ClassName,x[O]if
Q and P=='ModuleScript'then return am(Q)end local R=v[O]local function S(T)T=g(T)local U,V,W=O:GetFullName(),p(T,
'[^:]+:(%d+): (.+)')if not V or not j then return U..':*: '..(W or T)end V=h(V)local X=w[O]local Y=j[X]local Z=V-Y+1 if
Z<0 then Z='?'end return U..':'..Z..': '..W end if P=='LocalScript'or P=='Script'then local T,U=f(R)if not T then ah(S(U
),0)end else local T={f(R)}local U=l(T,1)if not U then local V=l(T,1)ah(S(V),0)end x[O]=T return am(T)end end function a
(O)local P=u[O]local function Q(R,...)local S={f(R,...)}local T=l(S,1)if not T then ah(S[1],3)end return am(S)end local
R=m(ag({},{__index=z,__newindex=function(R,S,T)z[S]=T end,__len=function()return#z end,__iter=function()return ak,z end}
))local S,T=m{version=ac,envname=ad,shared=R,script=c,require=e},P local function U(V,...)local W,X,Y=d(V),
'Attempted to call require with a non-ModuleScript','Attempted to call require with self'if W=='userdata'and A[V]then if
V.ClassName~='ModuleScript'then ah(X,2)elseif V==P then ah(Y,2)end return N(V)elseif W=='string'and o(V,1,1)~='@'then if
#V==0 then ah('Attempted to call require with empty string',2)end local Z=P if o(V,1,1)=='/'then Z=H elseif o(V,1,2)==
'./'then V=o(V,3)end local _ for an in q(V,'([^/]*)/?')do local ao=an if an=='..'then ao='Parent'end if ao~=''then local
ap=Z:FindFirstChild(ao)if not ap then local aq=Z.Parent if aq then ap=aq:FindFirstChild(ao)end end if ap then Z=ap
elseif an~=_ and an~='init'and an~='init.server'and an~='init.client'then ah('Virtual script path "'..V..'" not found',2
)end end _=an end if Z.ClassName~='ModuleScript'then ah(X,2)elseif Z==P then ah(Y,2)end return N(Z)end return Q(e,V,...)
end return S,T,U end for an,ao in ak,y do s(N,ao)end return N(H:GetChildren()[1])