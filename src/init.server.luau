local widget = plugin:CreateDockWidgetPluginGui("TestWidget", DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
		true
))
local constants = require(script.constants)
local server = require(script.plugin.server)

local CONSTANTS = constants

local pluginServer = server

server.init(plugin)

plugin.Unloading:Connect(function()
	server.close()
end)
