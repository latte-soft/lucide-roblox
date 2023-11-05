-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")

local StringUtils = require("modules/StringUtils")

local IconSourcesDir = "icons/src"
local IconDisplayDir = "icons/compiled/48px"
local IconDisplayFileType = "png"
local OutputPath = "md/icon-index.md"

local Output = [[
# Icon Index

This file contains an auto-generated index of icons, paired with their internal identifier that you can use with `lucide-roblox`'s API

| Icon | Identifier |
| :--: | ---------- |
]]

local RelativeUpString = ""
for _ in StringUtils.SplitFilePath(StringUtils.DirectoryOfFilePath(OutputPath) :: string) do
    RelativeUpString ..= "../"
end

local IconSourcesDirFileNames = fs.readDir(IconSourcesDir)
table.sort(IconSourcesDirFileNames)

for _, FileName in IconSourcesDirFileNames do
    local IconName = StringUtils.FileNameWithoutExtension(FileName)
    local IconDisplayFilePath = `{RelativeUpString}{IconDisplayDir}/{IconName}.{IconDisplayFileType}`

    Output ..= `| <img width="24px" height="24px" src="{StringUtils.SerializeStringData(IconDisplayFilePath)}" /> | \`{IconName}\` |\n`
end

fs.writeFile(OutputPath, Output)
