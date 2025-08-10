local Selection = game:GetService("Selection")

local react = require(script.Parent.Parent.packages.react)
local studiocomponents = require(script.Parent.Parent.packages.studiocomponents)

local useTheme = require(script.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.useTheme)
local server = require(script.Parent.Parent.plugin.server)
local plural = require(script.Parent.Parent.utils.plural)

local STUDIO_COMPONENTS_CONSTANTS = studiocomponents.Constants
local DEFAULT_TEXT_SIZE = STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize
local NO_PARTS_SELECTED_TEXT = "Select instances to track."

local e = react.createElement

type editModeTracker = {
	-- OnTrack: ({BasePart}) -> (),
	-- OnUntrack: ({BasePart}) -> (),
}

function EditModeTracker(props: editModeTracker)
	-- local onTrack = props.OnTrack
	-- local onUntrack = props.OnUntrack

	local theme = useTheme()

	local selectedInstances, setSelectedInstances = react.useState(server.getSelectedTrackedInstances())

	react.useEffect(function()
		local connection = Selection.SelectionChanged:Connect(function()
			setSelectedInstances(server.filterValidInstances(Selection:Get()))
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local hasSelectedInstances = #selectedInstances > 0

    print(hasSelectedInstances)

	return e("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		-- BackgroundTransparency = 1,
		BackgroundColor3 = theme:GetColor(
			Enum.StudioStyleGuideColor.MainBackground,
			Enum.StudioStyleGuideModifier.Default
		),
		BorderColor3 = theme:GetColor(
			Enum.StudioStyleGuideColor.Border,
			Enum.StudioStyleGuideModifier.Default
		),
	}, {
		ListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		TitleBar = e("Frame", {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = theme:GetColor(
				Enum.StudioStyleGuideColor.HeaderSection,
				Enum.StudioStyleGuideModifier.Default
			),
			BorderColor3 = theme:GetColor(
				Enum.StudioStyleGuideColor.Border,
				Enum.StudioStyleGuideModifier.Default
			),
		}, {
			TitleBarLabel = e(studiocomponents.Label, {
				Size = UDim2.new(1, 0, 0, DEFAULT_TEXT_SIZE * 2),
				Text = "Instance Tracker"
			}),
		}),
		SelectionInformation = e(studiocomponents.Label, {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, DEFAULT_TEXT_SIZE * 2),
			Text = if hasSelectedInstances then `{#selectedInstances} instance{plural(#selectedInstances)} selected.` else NO_PARTS_SELECTED_TEXT,
			TextColorStyle = if hasSelectedInstances then Enum.StudioStyleGuideColor.InfoText else Enum.StudioStyleGuideColor.MainText
		}),
		TrackButtons = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 3
		}, {
			ListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				ItemLineAlignment = Enum.ItemLineAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}),
			TrackPartButton = e(studiocomponents.MainButton, {
				Text = "Track",
				Size = UDim2.fromOffset(DEFAULT_TEXT_SIZE * 5, DEFAULT_TEXT_SIZE * 2),
				Disabled = not hasSelectedInstances,
				OnActivated = function()
                    server.trackInstances(selectedInstances)
					Selection:Set({})
				end,
			}),
			UntrackPartButton = e(studiocomponents.MainButton, {
				Text = "Untrack",
				Size = UDim2.fromOffset(DEFAULT_TEXT_SIZE * 5, DEFAULT_TEXT_SIZE * 2),
				Disabled = not hasSelectedInstances,
				OnActivated = function()
                    server.untrackInstances(selectedInstances)
					Selection:Set({})
				end,
			})
		})
	})

end

return EditModeTracker
