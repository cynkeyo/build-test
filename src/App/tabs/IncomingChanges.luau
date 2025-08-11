local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local studiocomponents =
	require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents)
local useTheme = require(
	script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.useTheme
)
local server = require(script.Parent.Parent.Parent.plugin.server)
local ChangedInstance = require(script.Parent.Parent.components.ChangedInstance)
local ChangesList = require(script.Parent.Parent.components.ChangesList)
local Padding = require(script.Parent.Parent.components.Padding)

local STUDIO_COMPONENTS_CONSTANTS = studiocomponents.Constants
local DEFAULT_TEXT_SIZE = STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize

local e = react.createElement

export type incomingChangesProps = {
	changedInstances: { Instance },
}

function IncomingChanges(props: incomingChangesProps)
	local changedInstances = props.changedInstances

	local theme = useTheme()

	return e(studiocomponents.Background, {
		Size = UDim2.fromScale(1, 1),
		AutomaticSize = Enum.AutomaticSize.X,
	}, {
		Padding = e(Padding),
		ListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		TitleBar = e("Frame", {
			LayoutOrder = 0,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = theme:GetColor(
				Enum.StudioStyleGuideColor.HeaderSection,
				Enum.StudioStyleGuideModifier.Default
			),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default),
		}, {
			TitleBarLabel = e(studiocomponents.Label, {
				Size = UDim2.new(1, 0, 0, DEFAULT_TEXT_SIZE * 2),
				Text = "Incoming Changes",
			}),
		}),
		ChangeList = e(ChangesList, {
			changedInstances = changedInstances,
		}),
		QuickActionMenu = e("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			-- BackgroundTransparency = 1,
			BackgroundColor3 = theme:GetColor(
				Enum.StudioStyleGuideColor.MainBackground,
				Enum.StudioStyleGuideModifier.Default
			),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default),
		}, {
			ListLayout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			TitleBar = e("Frame", {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = theme:GetColor(
					Enum.StudioStyleGuideColor.HeaderSection,
					Enum.StudioStyleGuideModifier.Default
				),
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default),
			}, {
				TitleBarLabel = e(studiocomponents.Label, {
					Size = UDim2.new(1, 0, 0, DEFAULT_TEXT_SIZE * 2),
					Text = "Quick Actions",
				}),
			}),
			SaveButtons = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 3,
			}, {
				ListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					ItemLineAlignment = Enum.ItemLineAlignment.Center,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				}),
				AcceptOverOriginalButton = e(studiocomponents.MainButton, {
					Text = "Save over original",
					Size = UDim2.fromOffset(DEFAULT_TEXT_SIZE * 5, DEFAULT_TEXT_SIZE * 2),
					OnActivated = function()
						local trackIdList = {}

						for _, trackedInstance in pairs(changedInstances) do
							local trackId = server.getInstanceTrackId(trackedInstance)

							table.insert(trackIdList, trackId)
						end

						server.acceptOverOriginal(trackIdList)
					end,
				}),
				AcceptUnderFolderButton = e(studiocomponents.MainButton, {
					Text = "Save under folder",
					Size = UDim2.fromOffset(DEFAULT_TEXT_SIZE * 5, DEFAULT_TEXT_SIZE * 2),
					OnActivated = function()
						local trackIdList = {}

						for _, trackedInstance in pairs(changedInstances) do
							local trackId = server.getInstanceTrackId(trackedInstance)

							table.insert(trackIdList, trackId)
						end

						server.acceptUnderFolder(trackIdList)
					end,
				}),
			}),
			DeclineButton = e(studiocomponents.Button, {
				LayoutOrder = 4,
				Text = "Dismiss",
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, DEFAULT_TEXT_SIZE * 2)),
				OnActivated = function()
					local trackIdList = {}

					for _, trackedInstance in pairs(changedInstances) do
						local trackId = server.getInstanceTrackId(trackedInstance)

						table.insert(trackIdList, trackId)
					end

					server.declineChange(trackIdList)
				end,
			}),
		}),
	})
end

return IncomingChanges
