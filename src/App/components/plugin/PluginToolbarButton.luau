local react = require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local Button = require(script.Parent.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Components.Button)
local PluginToolbarContext = require(script.Parent.Parent.Parent.contexts.PluginToolbarContext)
local PluginToolbar = require(script.Parent.PluginToolbar)

export type pluginToolbarButtonProps = {
    id: string,
    text: string,
    tooltip: string,
    active: boolean?,
    iconAsset: string?,
    onClick: () -> (),
}

function PluginToolbarButton(props: pluginToolbarButtonProps)
    local id = props.id
    local text = props.text
    local tooltip = props.tooltip
    local active = if props.active == nil then false else props.active
    local iconAsset = props.iconAsset or ""
    local onClick = props.onClick
    local enabled = if props.onClick then true else false

    local toolbar: PluginToolbar = react.useContext(PluginToolbarContext)

    local toolbarButton = react.useRef(nil :: PluginToolbarButton?)

    react.useEffect(function()
        if toolbarButton.current ~= nil then
            toolbarButton.current:Destroy()
        end

        local newButton = toolbar:CreateButton(id, tooltip, iconAsset, text)
        newButton.ClickableWhenViewportHidden = true
        newButton.Enabled = enabled

        local connection = newButton.Click:Connect(onClick)

        newButton:SetActive(active)

        toolbarButton.current = newButton

        return function()
            connection:Disconnect()
        end
    end, {id})
    -- react.useEffect(function()
    --     if toolbarButton.current and onClick then 
    --         local connection = toolbarButton.current.Click:Connect(onClick)
    --
    --         return function()
    --             connection:Disconnect()
    --         end
    --     end
    --
    --     return
    -- end, {toolbarButton.current, onClick})

    react.useEffect(function()
        if toolbarButton.current then 
            toolbarButton.current:SetActive(active)
        end
    end, {toolbarButton.current, active})

    react.useEffect(function()
        if toolbarButton.current then 
            toolbarButton.current.Icon = iconAsset
        end
    end, {toolbarButton.current, iconAsset})


    react.useEffect(function()
        if toolbarButton.current then 
            toolbarButton.current.Enabled = enabled
        end
    end, {toolbarButton.current, enabled})

    return nil
end

return PluginToolbarButton
