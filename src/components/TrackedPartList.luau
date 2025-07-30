local CollectionService = game:GetService("CollectionService")

local react = require(script.Parent.Parent.packages.react)

local CONSTANTS = require(script.Parent.Parent.constants)
local studiocomponents = require(script.Parent.Parent.packages.studiocomponents)
local TrackedPart = require(script.Parent.TrackedPart)

local e = react.createElement

local function createTableFromId(parts: {BasePart}): {[string]: BasePart}
	local table = {}

	for _, part in pairs(parts) do
		table[part:GetAttribute(CONSTANTS.PLUGIN_INSTANCE_ID_ATTRIBUTE)] = part
	end

	return table
end

function TrackedPartList()
	local trackedParts, setTrackedParts = react.useState(createTableFromId(CollectionService:GetTagged(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)))

	react.useEffect(function()
		local instanceAddedConnection = CollectionService:GetInstanceAddedSignal(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG):Connect(function(part: BasePart)
			setTrackedParts(createTableFromId(CollectionService:GetTagged(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)))
		end)
		local instanceRemovedConnection = CollectionService:GetInstanceRemovedSignal(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG):Connect(function(part: BasePart)
			setTrackedParts(createTableFromId(CollectionService:GetTagged(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)))
		end)

		return function()
			instanceAddedConnection:Disconnect()
			instanceRemovedConnection:Disconnect()
		end
	end, {})

	local children = {}

	for key, part in pairs(trackedParts) do
		children[key] = e(TrackedPart, {
			key = key,
			Name = part.Name,
			OnActivated = function()
				print(part)
			end
		})
	end

	return e(studiocomponents.ScrollFrame, {
		Size = UDim2.fromScale(1, 1)
	}, children)
end

return TrackedPartList
