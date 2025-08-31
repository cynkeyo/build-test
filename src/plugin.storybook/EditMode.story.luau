local EditMode = require(script.Parent.Parent.App.tabs.EditMode)
local react = require(script.Parent.Parent.packages.react)
local react_roblox = require(script.Parent.Parent.packages[".pesde"]["jsdotlua_react-roblox@17.2.1"]["react-roblox"])
local PluginProvider = require(script.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Components.PluginProvider)
local ui_labs = require(script.Parent.Parent.packages["ui-labs"])
local server = require(script.Parent.Parent.server)


local e = react.createElement
local janitor = ui_labs.Environment.GetJanitor()
local plugin = ui_labs.Environment.Plugin

server.init(plugin)

janitor:Add(server, "close")

return {
	react = react,
	reactRoblox = react_roblox,
	story = function()

		return e(PluginProvider, {
			Plugin = ui_labs.Environment.Plugin
		}, {
			e(EditMode)
		})
	end,
}
