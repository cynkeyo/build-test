local PluginMenuContext = require(script.Parent.Parent.Parent.contexts.PluginMenuContext)
local react = require(script.Parent.Parent.Parent.packages.react)
local goodsignal = require(script.Parent.Parent.Parent.packages[".pesde"]["stravant_goodsignal@0.3.0"].goodsignal)

local usePlugin = require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.usePlugin)

local e = react.createElement

type pluginMenuProps = {
	id: string,
	title: string,
	icon: string,
	openMenu: goodsignal.Signal<()>,
	children: react.ReactNode
}

function PluginMenu(props: pluginMenuProps)
	local id = props.id
	local title = props.title
	local icon = props.icon or ""
	local openMenu = props.openMenu

	local plugin: Plugin = usePlugin()
	local menu, setMenu = react.useState(nil :: PluginMenu?)

	react.useEffect(function()
		local pluginMenu = plugin:CreatePluginMenu(id, title, icon)

		setMenu(pluginMenu)

		return function()
			pluginMenu:Destroy()
		end
	end, { id })

	react.useEffect(function()
		if menu then
			menu.Title = title
		end
	end, {title, menu or false})

	react.useEffect(function()
		if menu then
			menu.Icon = icon
		end
	end, {icon, menu or false})

	react.useEffect(function()
		local connection = openMenu:Connect(function()
			menu:ShowAsync()
		end)

		return function()
			connection:Disconnect()
		end
	end, {openMenu, menu or false})

	return e(
		PluginMenuContext.Provider,
		{ value = menu },
		if menu then props.children else nil
	)
end

return PluginMenu
