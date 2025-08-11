local constants = require(script.Parent.constants)
local react = require(script.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local PluginProvider = require(
	script.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Components.PluginProvider
)
local PluginWidget = require(script.components.plugin.PluginWidget)
local StudioEdit = require(script.pages.StudioEdit)
local EditMode = require(script.tabs.EditMode)
local e = react.createElement

export type appProps = {
	plugin: Plugin,
}

function App(props: appProps)
	local plugin = props.plugin

	return e(PluginProvider, {
		Plugin = plugin,
	}, {
		Widget = e(PluginWidget, {
			id = constants.PLUGIN_ID,
			title = `{constants.PLUGIN_NAME} {constants.PLUGIN_VERSION}`,
			enabled = true,
			minSize = Vector2.new(240, 240),
			initialFloatSize = Vector2.new(240, 240),
		}, e(StudioEdit)),
	})
end

return App
