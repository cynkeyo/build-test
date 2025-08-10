local react = require(script.Parent.Parent.Parent.packages.react)
local studiocomponents = require(script.Parent.Parent.Parent.packages.studiocomponents)

local TrackedInstanceExplorer = require(script.Parent.Parent.Parent.components.TrackedInstanceExplorer)
local EditModeTracker = require(script.Parent.Parent.Parent.components.EditModeTracker)
local Padding = require(script.Parent.Parent.Parent.components.Padding)
local useTheme = require(
	script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.useTheme
)

local STUDIO_COMPONENTS_CONSTANTS = studiocomponents.Constants
local DEFAULT_TEXT_SIZE = STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize

local e = react.createElement

function EditMode()
	local theme = useTheme()

	-- local openSelectedMenu = goodsignal.new()

	return e(studiocomponents.Background, {
		Size = UDim2.fromScale(1, 1),
		AutomaticSize = Enum.AutomaticSize.X,
	}, {
		Padding = e(Padding),
		ListLayout = e("UIListLayout", {
			Padding = UDim.new(0, DEFAULT_TEXT_SIZE),
		}),
		TrackMenu = e(EditModeTracker),
		TrackedPartMenu = e("Frame", {
			Size = UDim2.fromScale(1, 0),
			BackgroundColor3 = theme:GetColor(
				Enum.StudioStyleGuideColor.HeaderSection,
				Enum.StudioStyleGuideModifier.Default
			),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default),
			AutomaticSize = Enum.AutomaticSize.Y,
			-- BackgroundTransparency = 1
		}, {
			FlexItem = e("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Grow,
			}),
			ListLayout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			TitleBar = e(studiocomponents.Label, {
				Text = "Tracked Instances",
				TextColorStyle = Enum.StudioStyleGuideColor.BrightText,
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, DEFAULT_TEXT_SIZE * 2)),
			}),
			-- use container frame in this case
			ListContainer = e("Frame", {
				Size = UDim2.fromScale(1, 0),
				LayoutOrder = 2,
			}, {
				FlexItem = e("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Grow,
				}),
			}, {
				TrackedPartList = e(studiocomponents.ScrollFrame, {
					Size = UDim2.fromScale(1, 1),
				}, {
					e(TrackedInstanceExplorer),
				}),
			}),
		}),
	})
end

return EditMode
