local react = require(script.Parent.Parent.packages.react)
local studiocomponents = require(script.Parent.Parent.packages.studiocomponents)

function Padding()
    return react.createElement("UIPadding", {
        PaddingBottom = UDim.new(0, studiocomponents.Constants.DefaultTextSize),
        PaddingTop = UDim.new(0, studiocomponents.Constants.DefaultTextSize),
        PaddingRight = UDim.new(0, studiocomponents.Constants.DefaultTextSize),
        PaddingLeft = UDim.new(0, studiocomponents.Constants.DefaultTextSize),
    })
end

return Padding
