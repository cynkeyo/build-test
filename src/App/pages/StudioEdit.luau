local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local server = require(script.Parent.Parent.Parent.plugin.server)
local EditMode = require(script.Parent.Parent.tabs.EditMode)
local IncomingChanges = require(script.Parent.Parent.tabs.IncomingChanges)
local e = react.createElement

function StudioEdit()
    local changedInstances, setChangedInstances = react.useState(server.getChangedInstancesFromSession())

    react.useEffect(function()
        local connection = server.workingSessionChanged:Connect(function()
            setChangedInstances(server.getChangedInstancesFromSession())
        end)

        return function()
            connection:Disconnect()
        end
    end, {})

    print(changedInstances)

    if #changedInstances > 0 then
        return e(IncomingChanges, {
            changedInstances = changedInstances
        })
    end

    return e(EditMode)
end

return StudioEdit
