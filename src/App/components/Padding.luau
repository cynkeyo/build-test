local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local studiocomponents = require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents)

function Padding()
    return react.createElement("UIPadding", {
        PaddingBottom = UDim.new(0, studiocomponents.Constants.DefaultTextSize),
        PaddingTop = UDim.new(0, studiocomponents.Constants.DefaultTextSize),
        PaddingRight = UDim.new(0, studiocomponents.Constants.DefaultTextSize),
        PaddingLeft = UDim.new(0, studiocomponents.Constants.DefaultTextSize),
    })
end

return Padding
