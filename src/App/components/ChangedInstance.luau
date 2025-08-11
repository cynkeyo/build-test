local StudioService = game:GetService("StudioService")

local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local studiocomponents = require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents)
local useTheme = require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.useTheme)

local STUDIO_COMPONENTS_CONSTANTS = studiocomponents.Constants
local DEFAULT_COLOR = Enum.StudioStyleGuideColor.MainBackground
local SELECTED_COLOR = Color3.fromRGB(49, 59, 95)
local HOVER_COLOR = Enum.StudioStyleGuideColor.Button

local e = react.createElement

type trackedInstanceProps = {
	Name: string,
	ClassName: string,
	TrackId: string,
	LayoutOrder: number,
	OnAcceptOverOriginal: (trackId: string) -> (),
	OnAcceptUnderFolder: (trackId: string) -> (),
	OnDecline: (trackId: string) -> (),
}

function ChangedInstance(props: trackedInstanceProps)
	local name = props.Name
    local trackId = props.TrackId
	local layoutOrder = props.LayoutOrder
	local className = props.ClassName
	local onAcceptOverOriginal = props.OnAcceptOverOriginal
	local onAcceptUnderFolder = props.OnAcceptUnderFolder
	local onDecline = props.OnDecline

	local theme = useTheme()

	local ClassIcon = StudioService:GetClassIcon(className)

	return e("Frame", {
		Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 24)),
		BackgroundTransparency = 0,
		BackgroundColor3 = theme:GetColor(DEFAULT_COLOR),
		LayoutOrder = layoutOrder,
        BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default)
		-- BackgroundColor3 = Color3.fromRGB(49, 59, 95),
	}, {
		ListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize / 3),
		}),
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize / 2),
		}),
		Icon = e("ImageLabel", {
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Image = ClassIcon.Image,
			ImageRectSize = ClassIcon.ImageRectSize,
			ImageRectOffset = ClassIcon.ImageRectOffset,
		}),
		InstanceName = e(studiocomponents.Label, {
			LayoutOrder = 2,
			Text = name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColorStyle = Enum.StudioStyleGuideColor.BrightText,
            TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.fromOffset(0, studiocomponents.Constants.DefaultTextSize),
		}, {
			FlexItem = e("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Grow,
			}),
		}),
		Buttons = e("Frame", {
			LayoutOrder = 3,
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
            BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default)
		}, {
			ListLayout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			AcceptOverOriginalButton = e(studiocomponents.Button, {
				LayoutOrder = 1,
				Size = UDim2.fromOffset(24, 24),
				Icon = {
					Image = "rbxassetid://74738063772202",
					Size = Vector2.new(16, 16),
					RectSize = Vector2.new(16, 16),
					RectOffset = Vector2.new(0, 0),
				},
                OnActivated = function()
                    onAcceptOverOriginal(trackId)
                end,
			}),
			AcceptUnderFolderButton = e(studiocomponents.Button, {
				LayoutOrder = 2,
				Size = UDim2.fromOffset(24, 24),
				Icon = {
					Image = StudioService:GetClassIcon("Folder").Image,
					Size = Vector2.new(16, 16),
					RectSize = Vector2.new(16, 16),
					RectOffset = Vector2.new(0, 0),
				},
                OnActivated = function()
                    onAcceptUnderFolder(trackId)
                end,
			}),
			DeclineButton = e(studiocomponents.Button, {
				LayoutOrder = 2,
				Size = UDim2.fromOffset(24, 24),
				Icon = {
					Image = "rbxassetid://78931432174335",
					Size = Vector2.new(16, 16),
					RectSize = Vector2.new(16, 16),
					RectOffset = Vector2.new(0, 0),
				},
                OnActivated = function()
                    onDecline(trackId)
                end,
			}),
		}),
	})
end

return ChangedInstance
