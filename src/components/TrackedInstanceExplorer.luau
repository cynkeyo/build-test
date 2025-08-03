local CollectionService = game:GetService("CollectionService")
local Selection = game:GetService("Selection")

local react = require(script.Parent.Parent.packages.react)

local CONSTANTS = require(script.Parent.Parent.constants)
local studiocomponents = require(script.Parent.Parent.packages.studiocomponents)
local ExplorerTrackedInstance = require(script.Parent.ExplorerTrackedInstance)
local server = require(script.Parent.Parent.plugin.server)
local modifierKey = require(script.Parent.Parent.utils.modifierKey)

local e = react.createElement

type trackedInstance = {
	ref: Instance,
	selected: boolean,
	id: number
}

type modifierKeys = {
	shift: boolean,
	control: boolean
}

local function createTrackedInstancesTable(instances: {Instance}): {trackedInstance}
	local selectedInstances = {}

	for _, selectedInstance in pairs(Selection:Get()) do
		if server.isInstanceTracked(selectedInstance) then
			local id = server.getInstanceTrackId(selectedInstance)

			selectedInstances[id] = selectedInstance
		end
	end

	local trackedInstances = {}

	for i, instance in pairs(instances) do
		local id = server.getInstanceTrackId(instance)

		trackedInstances[i] = {
			ref = instance,
			selected = if selectedInstances[id] then true else false,
			id = id,
		}
	end

	return trackedInstances
end

function TrackedInstanceExplorer()
	local trackedInstances, setTrackedInstances = react.useState(createTrackedInstancesTable(server.getTrackedInstances()))
	local modifierKeysRef = react.useRef({
		shift = false,
		control = false
	} :: modifierKeys)
	local lastSelectedInstance = react.useRef(nil :: Instance?)

	react.useEffect(function()
		local instanceAddedConnection = server.instanceTracked:Connect(function()
			setTrackedInstances(createTrackedInstancesTable(server.getTrackedInstances()))
		end)
		local instanceRemovedConnection = server.instanceUntracked:Connect(function()
			setTrackedInstances(createTrackedInstancesTable(server.getTrackedInstances()))
		end)

		return function()
			instanceAddedConnection:Disconnect()
			instanceRemovedConnection:Disconnect()
		end
	end, {})

	react.useEffect(function()
		local connection = Selection.SelectionChanged:Connect(function()
			setTrackedInstances(createTrackedInstancesTable(server.getTrackedInstances()))
		end)

		return function()
			connection:Disconnect()
		end
	end)

	local updateModifierKeys = react.useCallback(function(_, inputObject: InputObject)
		task.wait()

		local currentModifierKeys = modifierKeysRef.current

		local state = inputObject.UserInputState == Enum.UserInputState.Begin
		local modifierKey = modifierKey(inputObject)

		if modifierKey == "shift" then
			currentModifierKeys.shift = state
		elseif modifierKey == "control" then
			currentModifierKeys.control = state
		end
	end)

	local onInstanceLeftClick = react.useCallback(function(instance, index)
		task.wait()
		print(index)

		local currentModifierKeys = modifierKeysRef.current

		if currentModifierKeys.control then
			print(trackedInstances[index])
			if trackedInstances[index].selected then
				Selection:Remove({instance})
			else
				Selection:Add({instance})
			end
		elseif currentModifierKeys.shift and lastSelectedIndex then
			-- If the index is greater than the last selected index we have to iterate up, otherwise go down.
			local increment = if lastSelectedIndex >= index then -1 else 1

			local instancesToSelect = {}

			for instanceIndex = (lastSelectedIndex + increment), index, increment do
				table.insert(instancesToSelect, trackedInstances[instanceIndex].ref)
			end

			Selection:Add(instancesToSelect)
		else
			Selection:Set({instance})
		end
		lastSelectedIndex = instance
	end, {})

	local onInstanceRightClick = react.useCallback(function(instance, index)
		Selection:Set({instance})


		setTrackedInstances(createTrackedInstancesTable(server.getTrackedInstances()))
		lastSelectedIndex = instance
	end, {})

	local children = {}

	for index, instance in pairs(trackedInstances) do
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

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		[react.Event.InputBegan] = updateModifierKeys,
		[react.Event.InputEnded] = updateModifierKeys,
		[react.Event.InputChanged] = updateModifierKeys,
	}, {
		e(studiocomponents.ScrollFrame, {
			Size = UDim2.fromScale(1, 1)
		}, children)
	})

end

return TrackedInstanceExplorer
