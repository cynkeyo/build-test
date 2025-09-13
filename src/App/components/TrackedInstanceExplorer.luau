local Selection = game:GetService("Selection")


local ExplorerTrackedInstance = require(script.Parent.ExplorerTrackedInstance)
local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local studiocomponents = require(script.Parent.Parent.Parent.packages[".pesde"]["sircfenner_studiocomponents@1.2.0"].studiocomponents)
local BuildTestServer = require(script.Parent.Parent.Parent.BuildTestServer)
local InstanceTracker = require(script.Parent.Parent.Parent.BuildTestServer.InstanceTracker)
local modifierKey = require(script.Parent.Parent.Parent.utils.modifierKey)

local e = react.createElement

type trackedInstance = {
	ref: Instance,
	selected: boolean,
	id: number
}

type explorerState = {
	instances: {trackedInstance},
	lastSelectedIndex: number?
}

type modifierKeys = {
	shift: boolean,
	control: boolean
}

local function createExplorerState(instances: {Instance}): explorerState
	local selectedTrackedInstances = InstanceTracker:getSelectedTracked()
	local lastSelectedTrackedInstance

    local selectedInstances = {}
	--
	for _, selectedInstance in pairs(Selection:Get()) do
		if InstanceTracker:isTracked(selectedInstance) then
			local id = InstanceTracker.getTrackId(selectedInstance)

			selectedInstances[id] = selectedInstance
			lastSelectedTrackedInstance = selectedInstance
		end
	end

	local trackedInstances = {}
    local i = 1
	for id, instance in pairs(instances) do
		trackedInstances[i] = {
			ref = instance,
			selected = if table.find(selectedTrackedInstances, instance) then true else false,
			id = id,
		}

        i += 1
	end

	local lastSelectedIndex

	for index, instance in pairs(trackedInstances) do
		if instance.ref == lastSelectedTrackedInstance then
			lastSelectedIndex = index
		end
	end

	return {
		instances = trackedInstances,
		lastSelectedIndex = lastSelectedIndex
	}
end

function TrackedInstanceExplorer()
	local explorerState, setExplorerState = react.useState(createExplorerState(InstanceTracker:getTracked()))
	local modifierKeysRef = react.useRef({
		shift = false,
		control = false
	} :: modifierKeys)

	react.useEffect(function()
		local trackChangedConnection = InstanceTracker.trackChanged:Connect(function()
			setExplorerState(createExplorerState(InstanceTracker:getTracked()))
        end)

		return function()
            trackChangedConnection:Disconnect()
		end
	end, {})

	react.useEffect(function()
		local connection = Selection.SelectionChanged:Connect(function()
			setExplorerState(createExplorerState(InstanceTracker:getTracked()))
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local updateModifierKeys = react.useCallback(function(_, inputObject: InputObject)
		local currentModifierKeys = modifierKeysRef.current

		-- Don't cancel any inputs if we simply exited the window.
		if inputObject.UserInputState == Enum.UserInputState.Change then
			return
		end

		local state = inputObject.UserInputState == Enum.UserInputState.Begin
		local modifierKey = modifierKey(inputObject)

		if modifierKey == "shift" then
			currentModifierKeys.shift = state
		elseif modifierKey == "control" then
			currentModifierKeys.control = state
		end
	end)

	local onInstanceLeftClick = react.useCallback(function(instance, index)
		local currentModifierKeys = modifierKeysRef.current
		local lastSelectedIndex = explorerState.lastSelectedIndex

		if currentModifierKeys.control then
			if explorerState.instances[index].selected then
				Selection:Remove({instance})
			else
				Selection:Add({instance})
			end
		elseif currentModifierKeys.shift and lastSelectedIndex then
			local increment = if lastSelectedIndex >= index then -1 else 1

			local instancesToSelect = {}

			for instanceIndex = (lastSelectedIndex + increment), index, increment do
				table.insert(instancesToSelect, explorerState.instances[instanceIndex].ref)
			end

			Selection:Add(instancesToSelect)
		else
			Selection:Set({instance})
		end
	end, {explorerState})

	local onInstanceRightClick = react.useCallback(function(instance)
		Selection:Set({instance})
	end, {})

	local children = {}

	for index, instance in pairs(explorerState.instances) do
		local id = instance.id

		children[id] = e(ExplorerTrackedInstance, {
			key = id,
			Instance = instance.ref,
			LayoutOrder = index,
			OnRightClick = onInstanceRightClick,
			OnLeftClick = onInstanceLeftClick,
			Selected = instance.selected
		})
	end

    -- NOTE: Use TextButton since it makes it easier to check for an unselect click
	return e("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		[react.Event.InputBegan] = updateModifierKeys,
		[react.Event.InputEnded] = updateModifierKeys,
		[react.Event.MouseButton1Click] = function()
			Selection:Set({})
		end,
	}, {
		e(studiocomponents.ScrollFrame, {
			Size = UDim2.fromScale(1, 1),
			Layout = {
				ClassName = "UIListLayout",
				SortOrder = Enum.SortOrder.LayoutOrder
			}
		}, children)
	})

end

return TrackedInstanceExplorer
