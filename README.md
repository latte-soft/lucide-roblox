[stars]: https://github.com/latte-soft/lucide-roblox/stargazers
[license]: https://github.com/latte-soft/lucide-roblox/blob/master/LICENSE.md
[latest-release]: https://github.com/latte-soft/lucide-roblox/releases/latest
[commits]: https://github.com/latte-soft/lucide-roblox/commits
[discord]: https://latte.to/discord

[wally-package]: https://wally.run/package/latte-soft/lucide-icons
[roblox-marketplace]: https://roblox.com/library/15279939717

[badges/stars]: https://img.shields.io/github/stars/latte-soft/lucide-roblox?label=Stars&logo=GitHub
[badges/license]: https://img.shields.io/badge/License-MIT%20AND%20ISC-8dba05
[badges/latest-release]: https://img.shields.io/github/v/release/latte-soft/lucide-roblox?label=Latest%20Release
[badges/last-modified]: https://img.shields.io/github/last-commit/latte-soft/lucide-roblox?label=Last%20Modifed
[badges/discord]: https://img.shields.io/discord/892211155303538748?label=Latte%20Softworks%20Discord&color=5865F2

[badges/wally]: repo-assets/wally-badge.svg
[badges/roblox-marketplace]: repo-assets/roblox-marketplace-badge.svg

[img/lucide-logo]: repo-assets/lucide-logo-dark.svg

# [![Lucide Logo][img/lucide-logo]](https://lucide.dev) Lucide Icons for Roblox

<!--[![Stars][badges/stars]][stars]--> [![License][badges/license]][license] [![Latest Release][badges/latest-release]][latest-release] [![Last Modified][badges/last-modified]][commits] [![Discord Server][badges/discord]][discord]

[![Get it from Wally][badges/wally]][wally-package] [![Get it from the Roblox Marketplace][badges/roblox-marketplace]][roblox-marketplace]

Library to Use the Lucide Icon Set (<https://lucide.dev>) in Roblox

Unlike the similar [plugin](https://kotera.7kayoh.net/lucide) made some time ago, this library exists to serve as a library/package that you can access *programmatically* at runtime in any other games, applications, plugins etc. You could even write a plugin frontend with this library to implement an icon picker if you wanted!

This library was originally made for the intent of use with the [Commander](https://github.com/commanderhq) project, but stands applicable to anything else as well.

## ⚙️ Installation

There are multiple methods of using the library in your project; you can download the model/script file directly, use the [Wally](https://wally.run) package manager, or `require()` the module ID from Roblox's official Developer Marketplace at runtime.

### Manual Download

From the [releases page](https://github.com/latte-soft/lucide-roblox/releases), on the latest published release, you can download either `lucide-roblox.rbxm`, or `lucide-roblox.luau` (build by the [Wax](https://github.com/latte-soft/wax) bundler) if you want to use the library from one module. From there, just import into your project/Studio, and you're done!

### Via the Wally Package Manager

If you're familiar with [Wally](https://wally.run), you can also import the `latte-soft/lucide-icons` package in your `wally.toml` file:

```toml
[dependencies]
Lucide = "latte-soft/lucide-icons@0.1.0"
```

### Get from the Roblox Developer Marketplace

If you really want to, you could even [take the model for your inventory][roblox-marketplace], and import it from Studio's `Toolbox` etc.

## 🔨 Usage/API

You must define a `Lucide` variable mapping to wherever the library's module is located; `ReplicatedStorage`, Wally's `Packages` directory, wherever.. (The `Lucide` variable name isn't a requirement, but it is what we're using to identify members of the API in the section)

For the sake of generalization, here's an example for if the module was under `ReplicatedStorage` in a standard game/workflow:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lucide = require(ReplicatedStorage.Lucide)
```

From here, you can use any of the API members listed below.

#### Sections

* [Constants](#constants)
* [Functions](#functions)
* [Types](#types)

### Constants

*   ```lua
    Lucide.PackageVersion: string
    ```

    The version of the `lucide-roblox` package currently in-use *(e.g. `0.1.0`)*

*   ```lua
    Lucide.LucideVersion: string
    ```

    The version of lucide Icons itself that's aligned with the current package version *(e.g. `0.292.0`)*

*   ```lua
    Lucide.IconNames: {string}
    ```

    An alphabetically-sorted array of every icon name/identifier accessible

### Functions

*   ```lua
    function Lucide.GetAsset(iconName: string, iconSize: number?): Asset
    ```

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

*   ```lua
    function Lucide.GetAllAssets(inputSize: number?): {Asset}
    ```

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

*   ```lua
    function Lucide.ImageLabel(iconName: string, imageSize: number?, propertyOverrides: {[string]: any}?): ImageLabel
    ```

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

### Types

*   ```lua
    export type Asset = {
        IconName: string, -- "icon-name"
        Id: number, -- 123456789
        Url: string, -- "rbxassetid://123456789"
        ImageRectSize: Vector2, -- Vector2.new(48, 48)
        ImageRectOffset: Vector2, -- Vector2.new(648, 266)
    }
    ```

## License

The `lucide-roblox` package itself is licensed under the MIT License, while Lucide Icons as a whole is licensed under the ISC License. (Derivatively compatible)

See the complete license notice at [LICENSE.md](LICENSE.md).
