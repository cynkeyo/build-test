local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")

local react = require(script.Parent.Parent.packages.react)
local studiocomponents = require(script.Parent.Parent.packages.studiocomponents)
local useTheme = require(script.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.useTheme)
local ui_labs = require(script.Parent.Parent.packages["ui-labs"])
local UserInputService = ui_labs.Environment.UserInput

local STUDIO_COMPONENTS_CONSTANTS = studiocomponents.Constants
local DEFAULT_COLOR = Enum.StudioStyleGuideColor.MainBackground
local SELECTED_COLOR = Color3.fromRGB(49, 59, 95)
local HOVER_COLOR = Enum.StudioStyleGuideColor.Button

local e = react.createElement
local selectedColor = Color3.fromRGB(49, 59, 95)

type trackedInstanceProps = {
	Instance: Instance,
	Selected: boolean,
	LayoutOrder: number,
	OnRightClick: (instance: Instance, index: number) -> (),
	OnLeftClick: (instance: Instance, index: number) -> (),
}

local function isInstanceSelected(instance)
	local currentInstanceSelected = false

	for _, selectedInstance in pairs(Selection:Get()) do
		if selectedInstance == instance then
			currentInstanceSelected = true
			break
		end
	end

	return currentInstanceSelected
end

function ExplorerTrackedInstance(props: trackedInstanceProps)
	local instance = props.Instance
	local layoutOrder = props.LayoutOrder
	local selected = props.Selected
	local onRightClick = props.OnRightClick
	local onLeftClick = props.OnLeftClick

	local theme = useTheme()

	local hover, setHover = react.useState(false)
	local instanceName, setInstanceName = react.useState(instance.Name)

	react.useEffect(function()
		local nameConnection = instance:GetPropertyChangedSignal("Name"):Connect(function()
			setInstanceName(instance.Name)
		end)

		return function()
			nameConnection:Disconnect()
		end
	end, {})

	local ClassIcon = StudioService:GetClassIcon(instance.ClassName)

	return e("TextButton", {
		Size = UDim2.new(
			UDim.new(1, 0),
			UDim.new(0, 24)
		),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		BackgroundTransparency = 0,
		BackgroundColor3 = if selected then SELECTED_COLOR
					elseif hover then theme:GetColor(HOVER_COLOR)
					else theme:GetColor(DEFAULT_COLOR),
		LayoutOrder = layoutOrder,
		-- BackgroundColor3 = Color3.fromRGB(49, 59, 95),
		Text = "",
		[react.Event.MouseEnter] = function()
			setHover(true)
		end,
		[react.Event.MouseLeave] = function()
			setHover(false)
		end,
		[react.Event.MouseButton2Click] = function()
			onRightClick(instance, layoutOrder)
		end,
		[react.Event.MouseButton1Click] = function()
			onLeftClick(instance, layoutOrder)
		end,
	}, {
		ListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize / 3)
		}),
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize / 2)
		}),
		Icon = e("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Image = ClassIcon.Image,
			ImageRectSize = ClassIcon.ImageRectSize,
			ImageRectOffset = ClassIcon.ImageRectOffset
		}),
		InstanceName = e(studiocomponents.Label, {
			Text = instanceName,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColorStyle = Enum.StudioStyleGuideColor.BrightText
		}),
	})
end

return ExplorerTrackedInstance
