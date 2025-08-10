local react = require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local usePlugin = require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.usePlugin)
local PluginMenuContext = require(script.Parent.Parent.Parent.contexts.PluginMenuContext)

type pluginActionProps = {
	id: string,
	text: string,
	statusTip: string,
	iconName: string?,
	allowBinding: boolean,
	triggered: () -> ()
}

function PluginAction(props: pluginActionProps)
	local id = props.id
	local text = props.text
	local statusTip = props.statusTip
	local iconName = props.iconName
	local allowBinding = props.allowBinding
	local triggered = props.triggered

	local plugin: Plugin = usePlugin()
	local menu: PluginMenu? = react.useContext(PluginMenuContext)

	local action, setAction = react.useState(nil :: PluginAction?)

	local createAction = react.useCallback(function(
		id: string,
		text: string,
		statusTip: string,
		iconName: string?,
		allowBinding: boolean
	)
		if menu then
			if allowBinding then
				local action = plugin:CreatePluginAction(id, text, statusTip, iconName, allowBinding)
				menu:AddAction(action)

				return action
			else
				return menu:AddNewAction(id, text, iconName)
			end
		else
			return plugin:CreatePluginAction(id, text, statusTip, iconName, true)
		end
	end, { plugin, menu or false})

	react.useEffect(function()
		local newAction = createAction(id, text, statusTip, iconName, allowBinding)

		setAction(newAction)

		return function()
			newAction:Destroy()	
		end
	end, {createAction, id, text, statusTip, iconName, allowBinding})

	react.useEffect(function()
		if action then
			local connection = action.Triggered:Connect(triggered)
			return function()
				connection:Disconnect()
			end
		end

		return
	end, { triggered, action or false})

	return nil
end

return PluginAction
