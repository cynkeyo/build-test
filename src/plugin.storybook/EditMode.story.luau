local react = require(script.Parent.Parent.packages.react)
local react_roblox = require(script.Parent.Parent.packages[".pesde"]["jsdotlua_react-roblox@17.2.1"]["react-roblox"])
local PluginProvider = require(script.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Components.PluginProvider)
local ui_labs = require(script.Parent.Parent.packages["ui-labs"])

local EditMode = require(script.Parent.Parent.plugin.tabs.EditMode)

local e = react.createElement

return {
	react = react,
	reactRoblox = react_roblox,
	story = function()
		local plugin = ui_labs.Environment.Plugin
		return e(PluginProvider, {
			Plugin = ui_labs.Environment.Plugin
		}, {
			e(EditMode)
		})
	end,
}
