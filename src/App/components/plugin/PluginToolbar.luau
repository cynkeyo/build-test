local react = require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local usePlugin = require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.usePlugin)
local PluginToolbarContext = require(script.Parent.Parent.Parent.contexts.PluginToolbarContext)

local e = react.createElement

export type pluginToolbarProps = {
	Name: string,
    children: react.ReactNode,
}

function PluginToolbar(props: pluginToolbarProps)
    local plugin = usePlugin()

	local name = props.Name

	local pluginToolbar: PluginToolbar?, setPluginToolbar = react.useState(nil :: PluginToolbar?)

	react.useEffect(function()
		local newToolbar = plugin:CreateToolbar(name)

		setPluginToolbar(newToolbar)

		return function()
			newToolbar:Destroy()
		end
	end, {})

	react.useEffect(function()
		if pluginToolbar then
			pluginToolbar.Name = name
		end
	end, { pluginToolbar, name })

	return e(PluginToolbarContext.Provider, {
		value = pluginToolbar,
	}, if pluginToolbar then props.children else nil)
end

return PluginToolbar
