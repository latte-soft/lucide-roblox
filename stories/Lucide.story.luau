-- MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

local Lucide = require(script.Parent.Lucide)

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

return function(target: Frame)
    local InnerFrame = ApplyToInstance(Instance.new("ScrollingFrame"), {
        Position = UDim2.fromOffset(20, 20),
        Size = UDim2.new(1, -40, 1, 0),

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 8,

        --BottomImage = "",
        --MidImage = "",
        --TopImage = "",
    })

    ApplyToInstance(Instance.new("UIGridLayout"), {
        Parent = InnerFrame,

        CellSize = UDim2.fromOffset(48, 48),
        CellPadding = UDim2.fromOffset(10, 10),
        
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })

    InnerFrame.Parent = target

    for _, IconName in Lucide.IconNames do
        Lucide.ImageLabel(IconName, 48, {
            Parent = InnerFrame
        })
    end
end
