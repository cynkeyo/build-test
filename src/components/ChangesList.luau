local ChangedInstance = require(script.Parent.ChangedInstance)
local react = require(script.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local studiocomponents = require(script.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents)
local server = require(script.Parent.Parent.plugin.server)
local e = react.createElement

type changesListProps = {
    changedInstances: {Instance}
}

function ChangesList(props: changesListProps)
    local changedInstances, setChangedInstances = react.useState(server.getChangedInstancesFromSession())

    print(changedInstances)

    react.useEffect(function()
        local connection = server.workingSessionChanged:Connect(function()
            setChangedInstances(server.getChangedInstancesFromSession())
        end)

        return function()
            connection:Disconnect()
        end
    end, {})

    local children = {}

    for index, changedInstance in pairs(changedInstances) do
        local trackId = server.getInstanceTrackId(changedInstance)
        
        children[trackId] = e(ChangedInstance, {
            LayoutOrder = index,
            key = trackId,
            TrackId = trackId,
            Name = changedInstance.Name,
            ClassName = changedInstance.ClassName,
            OnAcceptOverOriginal = function(trackId)
                server.acceptOverOriginal(trackId)
            end,
            OnAcceptUnderFolder = function(trackId)
                server.acceptUnderFolder(trackId)
            end,
            OnDecline = function(trackId)
                server.declineChange(trackId)
            end,
        })
    end

	return e("Frame", {
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
	}, {
		FlexItem = e("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Grow,
		}),
		List = e(studiocomponents.ScrollFrame, {
			Size = UDim2.fromScale(1, 1),
			Layout = {
				ClassName = "UIListLayout",
				Padding = UDim.new(0, 1),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
		}, children),
	})
end

return ChangesList
