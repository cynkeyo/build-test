local react = require(script.Parent.Parent.packages.react)
local react_roblox = require(script.Parent.Parent.packages[".pesde"]["jsdotlua_react-roblox@17.2.1"]["react-roblox"])

local EditMode = require(script.Parent.Parent.plugin.tabs.EditMode)

return {
	react = react,
	reactRoblox = react_roblox,
	story = function()
		local component = react.createElement(EditMode, {})

		return component
	end,
}
