--!nolint
--!nocheck
--!native
--!optimize 2

--[[
    Wax - A Fast Runtime Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics
    MIT License | Copyright (c) 2023-2024 Latte Softworks <https://latte.to>

    Wax Version: 0.4.1
]]

------------------------------------------------------------------------------------------------------

local a local aa,ab,ac,ad,ae,af,ag,ah,ai,aj,ak,al,b,c,d,e,f,g,h,i={function()local b,c,d=a(1)local e return(function(...
)if string.sub(_VERSION,1,4)~='Lune'then print
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
    lune run wax [subcommand] [options]

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
)end,[17]=function()local b,c,d=a(17)local e return(function(...)local f={}function f.FileType(g:string):string?local h=
string.match(g,'.%.([^%.]+)$')if h then h=string.lower(h)end return h end function f.FileNameFromPath(g:string):string?
return string.match(g,'[^/\\]+$')end function f.FileNameWithoutExtension(g:string,h:boolean?):string?h=if h==nil then
true else h if h then return string.match(g,'^(.+)%.')else return string.match(g,'^%.?[^%.]+')end end function f.
FilePathWithoutExtension(g:string,h:boolean?):string?local i,j=f.DirectoryOfFilePath(g),f.FileNameFromPath(g)if not i or
not j then return end local k=f.FileNameWithoutExtension(j,h)if not k then return end return i..k end function f.
DirectoryOfFilePath(g:string):string?local h=string.match(g,'^.*[/\\]')if not h or h==''then h='./'end return h end
function f.SplitStringByPattern(g:string,h:string)local i={}for j in string.gmatch(g,h)do table.insert(i,j)end return i
end function f.SplitFilePath(g:string)return f.SplitStringByPattern(g,'([^/\\]+)[/\\]?')end function f.LineCount(g:
string):number local h=1 for i in string.gmatch(g,'\n')do h+=1 end return h end function f.Replace(g:string,h:{[string]:
string}):string return string.gsub(g,'${([A-Za-z_][A-Za-z0-9_]*)}',h)end do local g={['"']='\\"',['\\']='\\\\',['\a']=
'\\a',['\b']='\\b',['\t']='\\t',['\n']='\\n',['\v']='\\v',['\f']='\\f',['\r']='\\r'}for h=0,255 do local i=string.char(h
)if not g[i]and(h<32 or h>126)then g[i]='\\'..h end end function f.SerializeStringData(h:string):string local i=string.
gsub(h,'[%z\\"\1-\31\127-\255]',g)return i end end return f end)()end,[9]=function()local b,c,d=a(9)local e return(
function(...)local f,g,h,i,j,k,l,m,n,o=table,ipairs,string,next,pcall,game,workspace,tostring,tonumber,getmetatable
local p,q,r,s,t,u,v,w,x,y,z,A=h.format,h.char,h.gsub,h.match,h.rep,h.sub,h.gmatch,f.find,f.concat,f.insert,(typeof or
type)do local B={'and','break','do','else','elseif','end','false','for','function','if','in','local','nil','not','or',
'repeat','return','then','true','until','while','continue'}A=setmetatable({},{__mode='k'})for C,D in i,B do A[D]=true
end end w=w or function(B,C)for D,E in g(B)do if E==C then return D end end return end local function B(C,D,...)local E,
F={...},z(C)if not w(E,F)then error(p('LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`',D,x(E,', '),F),0)end
return C end local C do local D={['"']='\\"',['\\']='\\\\',['\a']='\\a',['\b']='\\b',['\t']='\\t',['\n']='\\n',['\v']=
'\\v',['\f']='\\f',['\r']='\\r'}for E=0,255 do local F=q(E)if not D[F]and(E<32 or E>126)then D[F]='\\'..E end end
function C(E)return'"'..r(E,'[%z\\"\1-\31\127-\255]',D)..'"'end end local function D(E)local F=''for G in v(E,'%](=*)%]'
)do if#G>=#F then F=G..'='end end return'--['..F..'['..E..']'..F..']'end local E do local function F(G)local H,I=j(k.
FindService,k,G.ClassName)if H and I then return true end return false end function E(G)local H=G if not H then return
end local I=''while H do local J,K,L=H.Name,H.ClassName,H.Parent if L==k and F(H)then I=':GetService('..C(K)..')'..I
elseif not A[J]and s(J,'^[A-Za-z_][A-Za-z0-9_]*$')then I='.'..J..I else I='['..C(J)..']'..I end if L==k then I='game'..I
return I elseif L==l then I='workspace'..I return I end H=L end return end end local function F(G,H)B(G,'inputTable',
'table')B(H,'options','table','nil')if H then B(H.Prettify,'options.Prettify','boolean','nil')B(H.PrettyPrinting,
'options.PrettyPrinting','boolean','nil')B(H.IndentCount,'options.IndentCount','number','nil')B(H.OutputWarnings,
'options.OutputWarnings','boolean','nil')B(H.StackLimit,'options.StackLimit','number','nil')B(H.FunctionsReturnRaw,
'options.FunctionsReturnRaw','boolean','nil')B(H.UseInstancePaths,'options.UseInstancePaths','boolean','nil')B(H.
SerializeMathHuge,'options.SerializeMathHuge','boolean','nil')B(H._StackLevel,'options._StackLevel','number','nil')B(H.
_VisitedTables,'options._StackLevel','table','nil')end H=H or{}local I=(H.Prettify==nil and H.PrettyPrinting==nil and
false)or(H.Prettify~=nil and H.Prettify)or(H.PrettyPrinting and H.PrettyPrinting)local J,K,L,M,N,O,P,Q=H.IndentCount or(
I and 4)or 0,(H.OutputWarnings==nil and true)or H.OutputWarnings,H.StackLimit or 500,(H.FunctionsReturnRaw==nil and
false)or H.FunctionsReturnRaw,(H.UseInstancePaths==nil and true)or H.UseInstancePaths,(H.SerializeMathHuge==nil and true
)or H.SerializeMathHuge,H._StackLevel or 1,H._VisitedTables or{[G]=true}if P>=L then return
'{--[[LuaEncode: Stack level limit of `'..L..'` reached]]}'end local R,S,T,U,V,W=(O and'math.huge')or'1/0',(O and
'-math.huge')or'-1/0',(I and'\n')or'',(I and', ')or',',(I and' ')or'',t(' ',J)W=(I and t(W,P))or W local X,Y,Z=(#W>0 and
u(W,1,-J-1))or'',1,{}do local function _(aa,ab)local ac=Z[aa](ab,false)return ac end local function aa(...)local ab={}
for ac,ad in i,{...}do y(ab,_(z(ad),ad))end return x(ab,U)end local function ab(ac,ad)return
[[(function(v, p) for pn, pv in next, p do v[pn] = pv end return v end)(]]..x({ac,_('table',ad)},U)..')'end Z.number=
function(ac,ad)if ad and ac==Y then Y=Y+1 return nil,true end if ac==1/0 then return R elseif ac==-1/0 then return S end
return p('%.14g',ac)end Z.string=function(ac,ad)if ad and not A[ac]and s(ac,'^[A-Za-z_][A-Za-z0-9_]*$')then return ac,
true end return C(ac)end Z.table=function(ac,ad)do local ae=Q[ac]if ae then return p(
'{--[[LuaEncode: Duplicate reference%s]]}',(ac==G and' (of parent)')or'')end Q[ac]=true end local ae=setmetatable({},{
__index=H})do ae.Prettify=(ad and false)or I ae.IndentCount=(ad and((not I and J)or 1))or J ae._StackLevel=(ad and 1)or
P+1 ae._VisitedTables=Q end return F(ac,ae)end Z.boolean=function(ac)return ac and'true'or'false'end Z['nil']=function(
ac)return'nil'end Z['function']=function(ac)if M then return ac()end return
[=[function() --[[LuaEncode: `options.FunctionsReturnRaw` false; can't serialize functions]] return end]=]end Z.Axes=
function(ac)local ad,ae={},{['Enum.Axis.X']=ac.X,['Enum.Axis.Y']=ac.Y,['Enum.Axis.Z']=ac.Z}for af,ag in i,ae do if ag
then y(ad,af)end end return'Axes.new('..x(ad,U)..')'end Z.BrickColor=function(ac)return'BrickColor.new('..(I and _(
'string',ac.Name))or ac.Number..')'end Z.CFrame=function(ac)return'CFrame.new('..aa(ac:components())..')'end Z.
CatalogSearchParams=function(ac)return ab('CatalogSearchParams.new()',{SearchKeyword=ac.SearchKeyword,MinPrice=ac.
MinPrice,MaxPrice=ac.MaxPrice,SortType=ac.SortType,CategoryFilter=ac.CategoryFilter,BundleTypes=ac.BundleTypes,
AssetTypes=ac.AssetTypes})end Z.Color3=function(ac)return'Color3.new('..aa(ac.R,ac.G,ac.B)end Z.ColorSequence=function(
ac)return'ColorSequence.new('.._('table',ac.Keypoints)..')'end Z.ColorSequenceKeypoint=function(ac)return
'ColorSequenceKeypoint.new('..aa(ac.Time,ac.Value)..')'end Z.DateTime=function(ac)return'DateTime.fromUnixTimestamp('..
ac.UnixTimestamp..')'end Z.DockWidgetPluginGuiInfo=function(ac)local ad=m(ac)return'DockWidgetPluginGuiInfo.new('..aa(
Enum.InitialDockState[s(ad,'InitialDockState:(%w+)')],s(ad,'InitialEnabled:(%w+)')=='1',s(ad,
'InitialEnabledShouldOverrideRestore:(%w+)')=='1',n(s(ad,'FloatingXSize:(%w+)')),n(s(ad,'FloatingYSize:(%w+)')),n(s(ad,
'MinWidth:(%w+)')),n(s(ad,'MinHeight:(%w+)')))..')'end Z.Enum=function(ac)return'Enum.'..m(ac)end Z.EnumItem=function(ac
)return m(ac)end Z.Enums=function(ac)return'Enum'end Z.Faces=function(ac)local ad,ae={},{['Enum.NormalId.Top']=ac.Top,[
'Enum.NormalId.Bottom']=ac.Bottom,['Enum.NormalId.Left']=ac.Left,['Enum.NormalId.Right']=ac.Right,['Enum.NormalId.Back']
=ac.Back,['Enum.NormalId.Front']=ac.Front}for af,ag in i,ae do if ag then y(ad,af)end end return'Faces.new('..x(ad,U)..
')'end Z.FloatCurveKey=function(ac)return'FloatCurveKey.new('..aa(ac.Time,ac.Value,ac.Interpolation)..')'end Z.Font=
function(ac)return'Font.new('..aa(ac.Family,ac.Weight,ac.Style)..')'end Z.Instance=function(ac)if N then local ad=E(ac)
if ad then return ad end end return'nil'..V..D('Instance.new('.._('string',ac.ClassName)..')')end Z.NumberRange=function
(ac)return'NumberRange.new('..aa(ac.Min,ac.Max)..')'end Z.NumberSequence=function(ac)return'NumberSequence.new('.._(
'table',ac.Keypoints)..')'end Z.NumberSequenceKeypoint=function(ac)return'NumberSequenceKeypoint.new('..aa(ac.Time,ac.
Value,ac.Envelope)..')'end Z.OverlapParams=function(ac)return ab('OverlapParams.new()',{FilterDescendantsInstances=ac.
FilterDescendantsInstances,FilterType=ac.FilterType,MaxParts=ac.MaxParts,CollisionGroup=ac.CollisionGroup,
RespectCanCollide=ac.RespectCanCollide})end Z.PathWaypoint=function(ac)return'PathWaypoint.new('..aa(ac.Position,ac.
Action,ac.Label)..')'end Z.PhysicalProperties=function(ac)return'PhysicalProperties.new('..aa(ac.Density,ac.Friction,ac.
Elasticity,ac.FrictionWeight,ac.ElasticityWeight)..')'end Z.Random=function()return'Random.new()'end Z.Ray=function(ac)
return'Ray.new('..aa(ac.Origin,ac.Direction)..')'end Z.RaycastParams=function(ac)return ab('RaycastParams.new()',{
FilterDescendantsInstances=ac.FilterDescendantsInstances,FilterType=ac.FilterType,IgnoreWater=ac.IgnoreWater,
CollisionGroup=ac.CollisionGroup,RespectCanCollide=ac.RespectCanCollide})end Z.Rect=function(ac)return'Rect.new('..aa(ac
.Min,ac.Max)..')'end Z.Region3=function(ac)local ad,ae=ac.CFrame,ac.Size return'Region3.new('..aa(ad*CFrame.new(-ae/2),
ad*CFrame.new(ae/2))..')'end Z.Region3int16=function(ac)return'Region3int16.new('..aa(ac.Min,ac.Max)..')'end Z.TweenInfo
=function(ac)return'TweenInfo.new('..aa(ac.Time,ac.EasingStyle,ac.EasingDirection,ac.RepeatCount,ac.Reverses,ac.
DelayTime)..')'end Z.RotationCurveKey=function(ac)return'RotationCurveKey.new('..aa(ac.Time,ac.Value,ac.Interpolation)..
')'end Z.UDim=function(ac)return'UDim.new('..aa(ac.Scale,ac.Offset)..')'end Z.UDim2=function(ac)return'UDim2.new('..aa(
ac.X.Scale,ac.X.Offset,ac.Y.Scale,ac.Y.Offset)..')'end Z.Vector2=function(ac)return'Vector2.new('..aa(ac.X,ac.Y)..')'end
Z.Vector2int16=function(ac)return'Vector2int16.new('..aa(ac.X,ac.Y)..')'end Z.Vector3=function(ac)return'Vector3.new('..
aa(ac.X,ac.Y,ac.Z)..')'end Z.Vector3int16=function(ac)return'Vector3int16.new('..aa(ac.X,ac.Y,ac.Z)..')'end Z.userdata=
function(ac)if o(ac)then return'newproxy(true)'else return'newproxy()'end end end local aa=''for ab,ac in i,G do local
ad,ae=z(ab),z(ac)if Z[ad]and Z[ae]then local af,ag,_,ah,ai=(I and T..W)or'',false,j(Z[ad],ab,true)local aj,ak=j(Z[ae],ac
,false)if _ and aj and ak then local al=ah and((ai and ah)or p('[%s]',ah))..((I and' = ')or'=')or''af=af..al..ak ag=true
elseif K then local al=p('LuaEncode: Failed to encode %s of DataType `%s`: %s',(not _ and'key')or(not aj and'value')or
'key/value',ae,(not _ and C(ah))or(not aj and C(ak))or'(Failed to get error message)')af=af..D(al)end if i(G,ab)then if
ag then af=af..','end else af=af..T..X end aa=aa..af end end aa='{'..aa..'}'return aa end return F end)()end,[15]=
function()local aa,ab,ac=a(15)local ad return(function(...)local ae=ac'@lune/fs'local function af(ag:string,ah:{string}?
):{string}if not string.match(ag,'[/\\]$')then ag..='/'end local ai=ah or{}for aj,ak in ae.readDir(ag)do if ae.isFile(ak
)then table.insert(ai,ag..ak)else af(ag..ak..'/',ai)end end return ai end return af end)()end,[11]=function()local aa,ab
,ac=a(11)local ad return(function(...)local ae,af=ac'@lune/process',{}function af.CommandExists(ag:string):boolean if ae
.os~='windows'then return ae.spawn('type',{ag},{shell=true}).ok end return true end function af.CheckCommands(ag:{string
})for ah,ai in ag do assert(af.CommandExists(ai),`Required command "{ai}" no found in your PATH environment variable, is it not installed?`
)end end return af end)()end,[5]=function()local aa,ab,ac=a(5)local ad return(function(...)local ae,af=ac'@lune/serde',{
generator={name='dense',column_span=120},rules={'convert_index_to_field','compute_expression','group_local_assignment',
'filter_after_early_return','remove_comments','remove_empty_do','remove_function_call_parens','remove_nil_declaration',
'remove_method_definition','remove_spaces','remove_unused_if_branch','remove_unused_while',{rule='rename_variables',
include_functions=true}}}return ae.encode('json',af,false)end)()end,[3]=function()local aa,ab,ac=a(3)local ad return(
function(...)local ae,af,ag=ac'@lune/luau',ac'@lune/roblox',ac'libraries/LuneUtils'local ah,ai,aj,ak,al,b,c=ag.Log,ag.
StringUtils,ac'libraries/LuaEncode',ac'data/Version',ac'data/Template',8,{Folder=1,ModuleScript=2,Script=3,LocalScript=4
,StringValue=5}local function d(e:string|{roblox.Instance},f:string?,g:boolean?,h:number?,i:boolean?):(string,number)
local j,k,l,m=f or'WaxRuntime',if g==nil then true else g,h or 0,if i==nil then true else i local function n(o,...)if m
then o(...)end end local o,p,q,r,s,t,u,v,w=k==false,if type(e)=='string'then af.deserializeModel(e)else e,os.clock(),0,{
},{},{},{},{}local function x(y)table.insert(w,y)local z={}for A,B in y:GetChildren()do z[B]=x(B)end return z end local
y=p for z,A in y do v[A]=x(A)end local function B(C,D,E:string?)E=E or C.Name local F,G=table.find(w,C),C.ClassName
local H=c[G]if not H then ah.Warn(`Skipping instance of ClassName "{G}", as it isn't supported in bundling`)return end
local I=G=='LocalScript'or G=='Script'local J,K=I or G=='ModuleScript',{[1]=F,[2]=H}if J and not(I and C.Disabled)then
local L=C.Source n(ah.Info,`Compile-checking {C.ClassName} "{E}"..`)local M,N=pcall(ae.compile,L)if M then u[F]=ai.
LineCount(L)+1 t[F]=function()return'function()local wax,script,require=ImportGlobals('..F..
')local ImportGlobals return (function(...)'..L..'\nend)() end'end else local O=string.match(tostring(N),
'%w* ?:%d*: ?([^\n]*)\n')ah.Warn(`WARNING: {C.ClassName} "{E}" failed to compile: {O or
'[Failed to parse compiler error]'}`)r+=1 u[F]=1 t[F]=function()return`function()error("[AOT COMPILER ERROR] {ai.
SerializeStringData(O)}")end`end end end local L={[1]=C.Name}if G=='StringValue'then L.Value=C.Value end if C.Name~=G
then K[3]=L end if next(D)then local M={}for N,O in D do local P=B(N,O,`{E}.{N.Name}`)if P then table.insert(M,P)end end
K[4]=M end return K end for C,D in v do local E=B(C,D)if E then table.insert(s,E)end end local E={}if o then local F=l+b
for G,H in u do E[G]=F F+=H end end local F=os.clock()n(ah.Info,`Finished bundling model data in {string.format('%.4f',F
-q)} (seconds)`)local G=if k==false then true else false local H,I,J=aj(s,{Prettify=G,StackLimit=math.huge}),aj(t,{
Prettify=G,FunctionsReturnRaw=true}),if not o then'nil'else aj(E,{Prettify=G})local K=ai.Replace(al,{Version=ai.
SerializeStringData(ak),EnvName=ai.SerializeStringData(j),ObjectTree=H,ClosureBindings=I,LineOffsets=J})if#y==1 and y[1]
.ClassName=='ModuleScript'then K..=
[[

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot:GetChildren()[1])]]else
for L,M in next,y do if M.ClassName=='ModuleScript'and M.Name=='MainModule'then K..=
[[

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot.MainModule)]]break end
end end return K,r end return d end)()end,[7]=function()local aa,ab,ac=a(7)local ad return(function(...)return'0.4.1'end
)()end,[12]=function()local aa,ab,ac=a(12)local ad return(function(...)local ae=ac'@lune/fs'local function af(ag:{[
string]:any},ah:string?)for ai,aj in ag do local ak,al=if ah then`{ah}/{ai}`else ai,type(aj)if al=='table'then if not ae
.isDir(ak)then ae.writeDir(ak)end af(aj,ak)elseif al=='string'and not ae.isFile(ak)then ae.writeFile(ak,aj)end end end
return af end)()end,[13]=function()local aa,ab,ac=a(13)local ad return(function(...)local ae=ac'@lune/stdio'local af,ag=
{Reset=ae.color'reset'..ae.style'reset',Red=ae.color'red',Yellow=ae.color'yellow',Bold=ae.style'bold'},{}function ag.
Info(ah:string,ai:string?)ai=ai or'\n'ae.write(`\u{2219} {ah}{ai}`)end function ag.Error(ah:string,ai:string?)ai=ai or
'\n'ae.ewrite(`{af.Bold..af.Red}\u{2219} {ah}{af.Reset}{ai}`)end function ag.Warn(ah:string,ai:string?)ai=ai or'\n'ae.
write(`{af.Bold..af.Yellow}\u{2219} {ah}{af.Reset}{ai}`)end function ag.InternalError(ah:string,ai:string?)ag.Error(
'[INTERNAL ERROR] '..ah,ai)end return ag end)()end,[10]=function()local aa,ab,ac=a(10)local ad return(function(...)
return{Log=ac'Log',StringUtils=ac'StringUtils',CommandUtils=ac'CommandUtils',WebhookQueue=ac'WebhookQueue',Run=ac'Run',
ParseArgs=ac'ParseArgs',EnsureFileTree=ac'EnsureFileTree',RecursiveReadDir=ac'RecursiveReadDir'}end)()end,[6]=function()
local aa,ab,ac=a(6)local ad return(function(...)return
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
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

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

    local Ref = {}
    local RefMetatable = {}

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

    setmetatable(Ref, RefMetatable)

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

        if ModuleArgType == "table" and RefChildren[module]  then
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
end)()end,[18]=function()local aa,ab,ac=a(18)local ad return(function(...)export type WebhookObject={[string]:any}local
ae,af,ag,ah,ai=ac'@lune/net',ac'@lune/task',ac'@lune/serde',false,{}local function aj(ak:number?)ak=ak or 3 if ah then
return end ah=true af.spawn(function()while ah do repeat af.wait()until#ai>=1 local al=ai[1]local b,c:WebhookObject=al[1
],al[2]local d=ag.encode('json',c)local e=ae.request{url=b,method='POST',headers={['Content-Type']='application/json'},
body=d}if not e.ok then print(`[!] Error in webhook request ({e.statusCode}): {e.body}\n[^^ Waiting 5 seconds..]`)af.
wait(5)continue end print(`[*] Discord Response ({e.statusCode}): {e.body}`)af.wait(ak)table.remove(ai,1)end end)end
local function ak()ah=false end local function al(b:string,c:WebhookObject)table.insert(ai,{[1]=b,[2]=c})end
local function b()ai={}end local function c()repeat af.wait()until#ai==0 end return{Start=aj,Stop=ak,Add=al,Clear=b,
Await=c}end)()end,[14]=function()local aa,ab,ac=a(14)local ad return(function(...)type OptionsInput={[string]:{string|
number|boolean|nil}}type OptionsOutput={[string]:string|number|boolean|nil}local ae,af=ac'@lune/process',ac'Log'
local function ag(ah:{string},ai:OptionsInput,aj:string?):OptionsOutput local function ak()if aj then print(`\n{aj}`)end
ae.exit(1)end local al={}for b,c in ah do local d,e=string.match(c,'([%w%-_]+)=(.+)')if not d then af.Error(`Command argument given, "{
c}" not in the proper \`option=value\` format, aborting..`)ak()end local f=ai[d]if f==nil then af.Error(`"{d}" isn't a valid option"`
)ak()end local g=f[1]if g=='boolean'then e=string.lower(e)e=if e=='true'then true elseif e=='false'then false else nil
if e==nil then af.Error(`"{e}" isn't a valid boolean type; expected "true" or "false"`)ak()end elseif g=='number'then e=
tonumber(e)if not e then af.Error(`Failed to convert given input "{e}" to a number value`)ak()end end al[d]=e end for d,
e in ai do local f,g=e[2],e[3]or false if not al[d]then if g then af.Error(`Option "{d}" required but not provided`)ak()
end al[d]=f end end return al end return ag end)()end,[16]=function()local aa,ab,ac=a(16)local ad return(function(...)
local ae,af=ac'@lune/process',ac'Log'local function ag(ah:string,ai:{string}?,aj:boolean?,ak:((string?)->())?):process.
SpawnResult local al,b=ai or{},if aj==nil then false else aj if not b then if#al==0 then af.Info(`> {ah}`)else af.Info(`> {
ah} {table.concat(al,' ')}`)end end local c=ae.spawn(ah,ai,{shell=if ae.os~='windows'then true else nil,stdio=if b then
'default'else'inherit'})if not c.ok and ak then ak(`Command above failed with status code {c.code}`)end return c end
return ag end)()end},{{1,2,{'Wax'},{{2,1,{'lib'},{{4,1,{'data'},{{5,2,{'DefaultDarkluaConfig'}},{7,2,{'Version'}},{6,2,{
'Template'}}}},{8,1,{'libraries'},{{10,2,{'LuneUtils'},{{17,2,{'StringUtils'}},{16,2,{'Run'}},{18,2,{'WebhookQueue'}},{
13,2,{'Log'}},{11,2,{'CommandUtils'}},{14,2,{'ParseArgs'}},{12,2,{'EnsureFileTree'}},{15,2,{'RecursiveReadDir'}}}},{9,2,
{'LuaEncode'}}}},{3,2,{'BundleModel'}}}}}}},'0.4.1','WaxRuntime',string,task,setmetatable,error,next,table,unpack,
coroutine,script,type,require,pcall,tostring,tonumber,_VERSION local j,k,l,m,n,o,p=aj.insert,aj.remove,aj.freeze or
function(j)return j end,al.wrap,ae.sub,ae.match,ae.gmatch if h and n(h,1,4)=='Lune'then local q,r=e(d,'@lune/task')if q
and r then af=r end end local q=af and af.defer local r,s,t,u,v,w,x,y,z=q or function(r,...)m(r)(...)end,{[1]='Folder',[
2]='ModuleScript',[3]='Script',[4]='LocalScript',[5]='StringValue'},{},{},{},{},{},{},{}local B,C={GetFullName={{},
function(B)local C,D=B.Name,B.Parent while D do C=D.Name..'.'..C D=D.Parent end return C end},GetChildren={{},function(B
)local C={}for D in ai,z[B]do j(C,D)end return C end},GetDescendants={{},function(B)local C={}for D in ai,z[B]do j(C,D)
for E,F in ai,D:GetDescendants()do j(C,F)end end return C end},FindFirstChild={{'string','boolean?'},function(B,C,D)
local E=z[B]for F in ai,E do if F.Name==C then return F end end if D then for G in ai,E do return G:FindFirstChild(C,
true)end end end},FindFirstAncestor={{'string'},function(B,C)local D=B.Parent while D do if D.Name==C then return D end
D=D.Parent end end},WaitForChild={{'string','number?'},function(B,C)return B:FindFirstChild(C)end}},{}for D,E in ai,B do
local F,G,H=E[1],E[2],{}for I,J in ai,F do local K,L=o(J,'^([^%?]+)(%??)')H[I]={K,L}end C[D]=function(K,...)if not z[K]
then ah("Expected ':' not '.' calling member function "..D,2)end local L={...}for M,N in ai,H do local O=L[M]local P,Q,R
=c(O),N[1],N[2]if O==nil and not R then ah('Argument '..O..' missing or nil',3)end if Q~='any'and P~=Q and not(P=='nil'
and R)then ah('Argument '..M..' expects type "'..Q..'", got "'..P..'"',2)end end return G(K,...)end end local function F
(G,H,I)local J,K=(ag({},{__mode='k'}))local function L(M)ah(M..' is not a valid (virtual) member of '..G..' "'..H..'"',3
)end local function M(N)ah('Unable to assign (virtual) property '..N..'. Property is read only',3)end local N,O={},{}O.
__metatable=false O.__index=function(P,Q)if Q=='ClassName'then return G elseif Q=='Name'then return H elseif Q=='Parent'
then return I elseif G=='StringValue'and Q=='Value'then return K else local R=C[Q]if R then return R end end for R in ai
,J do if R.Name==Q then return R end end L(Q)end O.__newindex=function(P,Q,R)if Q=='ClassName'then M(Q)elseif Q=='Name'
then H=R elseif Q=='Parent'then if R==N then return end if I~=nil then z[I][N]=nil end I=R if R~=nil then z[R][N]=true
end elseif G=='StringValue'and Q=='Value'then K=R else L(Q)end end O.__tostring=function()return H end ag(N,O)z[N]=J if
I~=nil then z[I][N]=true end return N end local function G(H,I)local J,K,L,M=H[1],H[2],H[3],H[4]local N=s[K]local O=L
and k(L,1)or N local P=F(N,O,I)t[J]=P if L then for Q,R in ai,L do P[Q]=R end end if M then for Q,R in ai,M do G(R,P)end
end return P end local H=F('Folder','['..ad..']')for I,J in ai,ab do G(J,H)end for K,L in ai,aa do local M=t[K]u[M]=L v[
M]=K local N=M.ClassName if N=='LocalScript'or N=='Script'then j(x,M)end end local function M(N)local O,P=N.ClassName,w[
N]if P and O=='ModuleScript'then return ak(P)end local Q=u[N]local function R(S)S=f(S)local T,U,V=N:GetFullName(),o(S,
'[^:]+:(%d+): (.+)')if not U or not i then return T..':*: '..(V or S)end U=g(U)local W=v[N]local X=i[W]local Y=U-X+1 if
Y<0 then Y='?'end return T..':'..Y..': '..V end if O=='LocalScript'or O=='Script'then local S,T=e(Q)if not S then ah(R(T
),0)end else local S={e(Q)}local T=k(S,1)if not T then local U=k(S,1)ah(R(U),0)end w[N]=S return ak(S)end end function a
(N)local O=t[N]local function P(Q,...)local R={e(Q,...)}local S=k(R,1)if not S then ah(R[1],3)end return ak(R)end local
Q=l(ag({},{__index=y,__newindex=function(Q,R,S)y[R]=S end,__len=function()return#y end,__iter=function()return ai,y end}
))local R,S=l{version=ac,envname=ad,shared=Q,script=b,require=d},O local function T(U,...)local V,W,X=c(U),
'Attempted to call require with a non-ModuleScript','Attempted to call require with self'if V=='table'and z[U]then if U.
ClassName~='ModuleScript'then ah(W,2)elseif U==O then ah(X,2)end return M(U)elseif V=='string'and n(U,1,1)~='@'then if#U
==0 then ah('Attempted to call require with empty string',2)end local Y=O if n(U,1,1)=='/'then Y=H elseif n(U,1,2)=='./'
then U=n(U,3)end local Z for _ in p(U,'([^/]*)/?')do local am=_ if _=='..'then am='Parent'end if am~=''then local an=Y:
FindFirstChild(am)if not an then local ao=Y.Parent if ao then an=ao:FindFirstChild(am)end end if an then Y=an elseif _~=
Z and _~='init'and _~='init.server'and _~='init.client'then ah('Virtual script path "'..U..'" not found',2)end end Z=_
end if Y.ClassName~='ModuleScript'then ah(W,2)elseif Y==O then ah(X,2)end return M(Y)end return P(d,U,...)end return R,S
,T end for am,an in ai,x do r(M,an)end return M(H:GetChildren()[1])