local React = require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local ReactRoblox =
	require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-roblox@17.2.1"]["react-roblox"])
local PluginContext = require(
	script.Parent.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Contexts.PluginContext
)
local usePlugin = require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.usePlugin)

local e = React.createElement

export type widgetProps = {
	id: string,
	title: string,
	enabled: boolean?,
	minSize: Vector2?,
	initialFloatSize: Vector2?,
	children: React.ReactNode,
}

function Widget(props: widgetProps)
	local plugin = usePlugin()

	local id = props.id
	local title = props.title
	local enabled = if props.enabled ~= nil then props.enabled else true
	local minSize = props.minSize or Vector2.zero
	local initialFloatSize = props.initialFloatSize or Vector2.new(200, 200)
    local children = props.children

	local dockWidget: DockWidgetPluginGui?, setDockWidget = React.useState(nil :: DockWidgetPluginGui?)

	local dockWidgetInfo = React.useMemo(function()
		return DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
            enabled,
			true,
			initialFloatSize.X,
			initialFloatSize.Y,
			minSize.X,
			minSize.Y
		)
	end, {})

    React.useEffect(function()
        local newWidget = plugin:CreateDockWidgetPluginGui(id, dockWidgetInfo)
        newWidget.Name = title
        newWidget.Title = title
        newWidget.ResetOnSpawn = false
        newWidget.Enabled = enabled
        setDockWidget(newWidget)

        return function()
            newWidget:Destroy()
        end
    end, {id, dockWidgetInfo})

    React.useEffect(function()
        if dockWidget then
            dockWidget.Title = title
        end
    end, {title})

    React.useEffect(function()
        if dockWidget then
            dockWidget.Enabled = enabled
        end
    end, {enabled})

    return if dockWidget then ReactRoblox.createPortal(children, dockWidget) else nil
end

return Widget
