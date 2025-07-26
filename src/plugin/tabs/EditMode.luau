local react = require(script.Parent.Parent.Parent.packages.react)
local studiocomponents = require(script.Parent.Parent.Parent.packages.studiocomponents)

local Padding = require(script.Parent.Parent.Parent.components.Padding)
local TrackedPart = require(script.Parent.Parent.Parent.components.TrackedPart)
local PluginAction = require(script.Parent.Parent.Parent.components.plugin.PluginAction)
local PluginMenu = require(script.Parent.Parent.Parent.components.plugin.PluginMenu)
local constants = require(script.Parent.Parent.Parent.constants)
local useTheme = require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.useTheme)
local goodsignal = require(script.Parent.Parent.Parent.packages[".pesde"]["stravant_goodsignal@0.3.0"].goodsignal)

local CONSTANTS = constants
local STUDIO_COMPONENTS_CONSTANTS = studiocomponents.Constants
local DEFAULT_TEXT_SIZE = STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize

local e = react.createElement

function EditMode()
	local theme = useTheme()

	local openSelectedMenu = goodsignal.new()

	return e(studiocomponents.Background, {
		Size = UDim2.fromScale(1, 1),
		AutomaticSize = Enum.AutomaticSize.X
	}, {
		Padding = e(Padding),
		ListLayout = e("UIListLayout", {
			Padding = UDim.new(0, DEFAULT_TEXT_SIZE)
		}),
		TrackMenu = e("Frame", {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.new(1,1,1),
		}, {
			ListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, DEFAULT_TEXT_SIZE)
			}),
			TrackPartButton = e(studiocomponents.MainButton, {
				Text = "Track",
				Size = UDim2.fromOffset(DEFAULT_TEXT_SIZE * 5, DEFAULT_TEXT_SIZE * 2)
			}),
			UntrackPartButton = e(studiocomponents.MainButton, {
				Text = "Untrack",
				Size = UDim2.fromOffset(DEFAULT_TEXT_SIZE * 5, DEFAULT_TEXT_SIZE * 2)
			})
		}),
		TrackedPartMenu = e("Frame", {
			Size = UDim2.fromScale(1, 0),
			BackgroundColor3 = theme:GetColor(
				Enum.StudioStyleGuideColor.HeaderSection,
				Enum.StudioStyleGuideModifier.Default
			),
			BorderColor3 = theme:GetColor(
				Enum.StudioStyleGuideColor.Border,
				Enum.StudioStyleGuideModifier.Default
			),
			AutomaticSize = Enum.AutomaticSize.Y
			-- BackgroundTransparency = 1
		}, {
			FlexItem = e("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Grow
			}),
			-- SizeConstraint = e("UISizeConstraint", {
			-- 	MaxSize = Vector2.new(
			-- 		math.huge,
			-- 		STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize * 30
			-- 	)
			-- }),
			ListLayout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			TitleBar = e(studiocomponents.Label, {
				Text = "Tracked Parts",
				TextColorStyle = Enum.StudioStyleGuideColor.BrightText,
				Size = UDim2.new(
					UDim.new(1, 0),
					UDim.new(0, DEFAULT_TEXT_SIZE * 2)
				)

			}),
			-- use container frame in this case
			ListContainer = e("Frame", {
				Size = UDim2.fromScale(1, 0),
				LayoutOrder = 2
			}, {
				FlexItem = e("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Grow
				}),
			}, {
				TrackedPartList = e(studiocomponents.ScrollFrame, {
					Size = UDim2.fromScale(1, 1)
				}, {
					ActionMenu = e(PluginMenu, {
						id = CONSTANTS.PLUGIN_MENUS.SELECTED_TRACKED_PART.ID,
						title = CONSTANTS.PLUGIN_MENUS.SELECTED_TRACKED_PART.TITLE,
						icon = CONSTANTS.PLUGIN_MENUS.SELECTED_TRACKED_PART.ICON,
						openMenu = openSelectedMenu,
					}, {
						AddPart = e(PluginAction, {
							id = CONSTANTS.PLUGIN_ACTIONS.TRACK_PART.ID,
							text = CONSTANTS.PLUGIN_ACTIONS.TRACK_PART.TEXT,
							iconName = CONSTANTS.PLUGIN_ACTIONS.TRACK_PART.ICON_NAME,
							statusTip = CONSTANTS.PLUGIN_ACTIONS.TRACK_PART.STATUS_TIP,
							triggered = function()
								print("yeah")
							end,
							allowBinding = CONSTANTS.PLUGIN_ACTIONS.TRACK_PART.ALLOW_BINDING
						}),
						RemovePart = e(PluginAction, {
							id = CONSTANTS.PLUGIN_ACTIONS.UNTRACK_PART.ID,
							text = CONSTANTS.PLUGIN_ACTIONS.UNTRACK_PART.TEXT,
							iconName = CONSTANTS.PLUGIN_ACTIONS.UNTRACK_PART.ICON_NAME,
							statusTip = CONSTANTS.PLUGIN_ACTIONS.UNTRACK_PART.STATUS_TIP,
							triggered = function()
								print("yeah")
							end,
							allowBinding = CONSTANTS.PLUGIN_ACTIONS.UNTRACK_PART.ALLOW_BINDING
						}),
						HighlightPart = e(PluginAction, {
							id = CONSTANTS.PLUGIN_ACTIONS.HIGHLIGHT_PART.ID,
							text = CONSTANTS.PLUGIN_ACTIONS.HIGHLIGHT_PART.TEXT,
							iconName = CONSTANTS.PLUGIN_ACTIONS.HIGHLIGHT_PART.ICON_NAME,
							statusTip = CONSTANTS.PLUGIN_ACTIONS.HIGHLIGHT_PART.STATUS_TIP,
							triggered = function()
								print("yeah")
							end,
							allowBinding = CONSTANTS.PLUGIN_ACTIONS.HIGHLIGHT_PART.ALLOW_BINDING
						}),
					}),
					e(TrackedPart, {
						OnActivated = function()
							print("asdasdasd")
							openSelectedMenu:Fire()
						end
					})
				})
			})
		})
	})
end

return EditMode
