local ChangedInstance = require(script.Parent.ChangedInstance)
local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local studiocomponents = require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents)
local BuildTestServer = require(script.Parent.Parent.Parent.BuildTestServer)
local DiffSynchronizer = require(script.Parent.Parent.Parent.BuildTestServer.DiffSynchronizer)
local DiffSynchronizer = BuildTestServer.DiffSynchronizer
local e = react.createElement

type changesListProps = {
    diffs: DiffSynchronizer.diffsType
}

function ChangesList(props: changesListProps)
    local diffs = props.diffs

    local children = {}
    local index = 0

    for diffId, diffData in pairs(diffs) do
        children[diffId] = e(ChangedInstance, {
            LayoutOrder = index,
            key = diffId,
            Name = diffData.instanceName,
            ClassName = diffData.className,
            OnAcceptOverOriginal = function()
                DiffSynchronizer:resolveDiffs({diffId}, "override")
            end,
            OnAcceptUnderFolder = function()
                DiffSynchronizer:resolveDiffs({diffId}, "dump")
            end,
            OnDecline = function()
                DiffSynchronizer:resolveDiffs({diffId}, "dismiss")
            end,
        })

        index += 1
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
