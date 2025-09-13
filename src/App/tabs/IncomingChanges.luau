local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local studiocomponents =
	require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents)
local useTheme = require(
	script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Hooks.useTheme
)
local BuildTestServer = require(script.Parent.Parent.Parent.BuildTestServer)
local DiffSynchronizer = require(script.Parent.Parent.Parent.BuildTestServer.DiffSynchronizer)
local Table = require(script.Parent.Parent.Parent.utils.Table)
local deepClone = require(script.Parent.Parent.Parent.utils.deepClone)
local DiffSynchronizer = BuildTestServer.DiffSynchronizer
local ChangedInstance = require(script.Parent.Parent.components.ChangedInstance)
local ChangesList = require(script.Parent.Parent.components.ChangesList)
local Padding = require(script.Parent.Parent.components.Padding)

local STUDIO_COMPONENTS_CONSTANTS = studiocomponents.Constants
local DEFAULT_TEXT_SIZE = STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize

local e = react.createElement

function IncomingChanges()
    local diffs, setDiffs = react.useState(DiffSynchronizer:getDiffs())

    react.useEffect(function()
        local connection = DiffSynchronizer.diffsChanged:Connect(function(diffs)
            setDiffs(deepClone(diffs))
        end)

        return function()
            connection:Disconnect()
        end
    end, {})

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
			diffs = diffs,
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
					Text = "Override",
					Size = UDim2.fromOffset(DEFAULT_TEXT_SIZE * 5, DEFAULT_TEXT_SIZE * 2),
					OnActivated = function()
						local diffIds = {}

						for diffId, _ in pairs(diffs) do
                            table.insert(diffIds, diffId)
						end

                        DiffSynchronizer:resolveDiffs(diffIds, "override")
					end,
				}),
				AcceptUnderFolderButton = e(studiocomponents.MainButton, {
					Text = "Save under dump",
					Size = UDim2.fromOffset(DEFAULT_TEXT_SIZE * 5, DEFAULT_TEXT_SIZE * 2),
					OnActivated = function()
						local diffIds = {}

						for diffId, _ in pairs(diffs) do
                            table.insert(diffIds, diffId)
						end

                        DiffSynchronizer:resolveDiffs(diffIds, "dump")
					end,
				}),
			}),
			DeclineButton = e(studiocomponents.Button, {
				LayoutOrder = 4,
				Text = "Dismiss",
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, DEFAULT_TEXT_SIZE * 2)),
				OnActivated = function()
                    local diffIds = {}

                    for diffId, _ in pairs(diffs) do
                        table.insert(diffIds, diffId)
                    end

                    DiffSynchronizer:resolveDiffs(diffIds, "dismiss")
				end,
			}),
		}),
	})
end

return IncomingChanges
