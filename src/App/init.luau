local constants = require(script.Parent.constants)
local react = require(script.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local PluginProvider = require(
	script.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Components.PluginProvider
)
local getRuntimeEnviroment = require(script.Parent.utils.getRuntimeEnviroment)
local PluginToolbar = require(script.components.plugin.PluginToolbar)
local PluginToolbarButton = require(script.components.plugin.PluginToolbarButton)
local PluginWidget = require(script.components.plugin.PluginWidget)
local StudioEdit = require(script.pages.StudioEdit)

local PLUGIN_DISPLAY_NAME = `{constants.PLUGIN_NAME} {constants.PLUGIN_VERSION}`

local e = react.createElement

export type appProps = {
	plugin: Plugin,
}

function App(props: appProps)
	local plugin = props.plugin

	local widgetOpen, setWidgetOpen = react.useState(false)

	local enviroment = getRuntimeEnviroment()

	return e(PluginProvider, {
		Plugin = plugin,
	}, {
		Toolbar = e(PluginToolbar, {
			Name = PLUGIN_DISPLAY_NAME,
		}, {
			OpenWidgetButton = e(PluginToolbarButton, {
				id = "OPEN_WIDGET_BUTTON",
				text = "Build Test",
				tooltip = "Open Plugin Widget",
				active = widgetOpen,
				iconAsset = "rbxassetid://72981511939628",
				onClick = function()
					setWidgetOpen(function(currentOpen)
						return not currentOpen
					end)
				end,
			}),
		}),
		Widget = e(PluginWidget, {
			id = constants.PLUGIN_ID,
			title = PLUGIN_DISPLAY_NAME,
			enabled = widgetOpen,
			minSize = Vector2.new(240, 240),
			onClose = function()
				setWidgetOpen(false)
			end,
			initialFloatSize = Vector2.new(240, 240),
		}, {
			StudioEdit = (enviroment == "studioEditMode") and e(StudioEdit),
		}),
	})
end

return App
