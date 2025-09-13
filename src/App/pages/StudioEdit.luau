local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local BuildTestServer = require(script.Parent.Parent.Parent.BuildTestServer)
local studiocomponents =
	require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents)
local Background = require(
	script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Components.Background
)
local Label = require(
	script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Components.Label
)
local TabContainer = require(
	script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents.Components.TabContainer
)
local Table = require(script.Parent.Parent.Parent.utils.Table)
local deepClone = require(script.Parent.Parent.Parent.utils.deepClone)
local Padding = require(script.Parent.Parent.components.Padding)
local DiffSynchronizer = BuildTestServer.DiffSynchronizer
local EditMode = require(script.Parent.Parent.tabs.EditMode)
local IncomingChanges = require(script.Parent.Parent.tabs.IncomingChanges)
local e = react.createElement

local STUDIO_COMPONENTS_CONSTANTS = studiocomponents.Constants
local DEFAULT_TEXT_SIZE = STUDIO_COMPONENTS_CONSTANTS.DefaultTextSize

function StudioEdit()
	local diffs, setDiffs = react.useState(DiffSynchronizer:getDiffs())

	react.useEffect(function()
		local connection = DiffSynchronizer.diffsChanged:Connect(function(diffs)
			setDiffs(deepClone(diffs))
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local selectedTab, setSelectedTab = react.useState("Tracker")

	if Table.length(diffs) > 0 then
		return e(IncomingChanges, {
			diffs = diffs,
		})
	end

	return e(TabContainer, {
		SelectedTab = selectedTab,
		OnTabSelected = setSelectedTab,
	}, {
		["Tracker"] = {
			LayoutOrder = 1,
			Content = e(EditMode),
		},
		["Info"] = {
			LayoutOrder = 2,
			Content = e("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				Padding = e(Padding),
				ListLayout = e("UIListLayout", {
					Padding = UDim.new(0, DEFAULT_TEXT_SIZE),
				}),
				Information = e(Label, {
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					Text = [[
                        [ Track Tab ]
                        - In this tab you'll select what instances the plugin will track. Any changes made in playtest mode on tracked instances will then carry over to the Incoming Changes tab
                        
                        [ Incoming Changes Tab ]
                        - In this tab you can do a few select actions:
                          - Override (➕): Save the changes made over the ORIGINAL tracked instance
                          - Dump (📁): Save the changes as a new instance that'll be saved under a session dump located in ServerStorage on the folder BuildTestDump
                          - Dismiss (❌): Ignore the changes made to the instance, removing it from the pending changes list.

                        [ Credits ]
                        @llirile: main plugin development
                        @xXTheR3DGamerXx: plugin feedback
                        @0x1437: instance serializer module provider
                        ]],
				}),
			}),
		},
	})
end

return StudioEdit
