local StarterGui = game:GetService("StarterGui")
--[[
--needs initialized:
-- - SessionManager
-- - DumpFolderManager
-- - InstanceTracker
--
--Manages diff synchronization, making changes to the working session
--]]

local goodsignal = require(script.Parent.Parent.packages[".pesde"]["stravant_goodsignal@0.3.0"].goodsignal)

local types = require(script.Parent.Parent.types)
local DumpFolderManager = require(script.Parent.DumpFolderManager)
local InstanceSerializer = require(script.Parent.InstanceSerializer)
local InstanceTracker = require(script.Parent.InstanceTracker)
local Session = require(script.Parent.Parent.utils.Session)
local recordedAction = require(script.Parent.Parent.utils.recordedAction)
local SessionManager = require(script.Parent.SessionManager)
local constants = require(script.Parent.Parent.constants)
local pluginActions = constants.PLUGIN_ACTIONS

export type diffType = "new" | "changed" | "none"
export type instanceDiff = {
    type: diffType,
    instanceName: string,
    className: string
}
export type diffsType = { [string]: instanceDiff }
export type resolveDiffType = "override" | "dump" | "dismiss"

local initialized = false
local currentWorkingSession: Session.ClassType
local diffs: diffsType = {}
local diffsChangedSignal = goodsignal.new() :: goodsignal.Signal<diffsType>
local sessionFetchedConnection: goodsignal.Connection

local function assertInitialization()
	assert(initialized, "DiffSynchronizer isn't initialized.")
end

local function getDiffFromSerializedInstance(
	trackId: string,
	serializedInstance: types.serializedInstance
): instanceDiff
	local currentInstance = InstanceTracker:getFromTrackId(trackId)

	local diffType = "none"

	if currentInstance then
		local currentSerialized = InstanceSerializer.serializeInstance(currentInstance)

		-- If the serialized data is not equal to currentSerialized, then it means changes were made
		if currentSerialized.data ~= serializedInstance.data then
			diffType = "changed"
		end
	else
		diffType = "new"
	end

	return {
		type = diffType,
		instanceName = if diffType == "new" then serializedInstance.name else currentInstance.Name,
        className = serializedInstance.className
	}
end

local function generateDiffsFromSession(session: Session.ClassType): diffsType
	local diffs = {}
	for id, serializedInstance in pairs(session:getInstanceDataDict()) do
		local diff = getDiffFromSerializedInstance(id, serializedInstance)

		-- diff type none means there is no change across sessions, skip
		if diff.type == "none" then
			continue
		end

		diffs[id] = diff
	end

	return diffs
end

local function overrideDiff(diffId: string)
	local instanceToOverride = InstanceTracker:getFromTrackId(diffId)
	local instanceData = currentWorkingSession:getInstanceDataFromId(diffId)

	InstanceSerializer.deserializeInstance(instanceData, instanceToOverride)
end

local function dumpDiff(diffId: string)
	local instanceData = currentWorkingSession:getInstanceDataFromId(diffId)
	local dumpFolder = DumpFolderManager:getSessionDumpFromSession(currentWorkingSession)

	local deserialized = InstanceSerializer.deserializeInstance(instanceData)
	deserialized.Parent = dumpFolder
end

local getActionDataFromResolveType
do
	local resolveToActionMap = {
		override = {
			id = pluginActions.ACCEPT_OVER_ORIGINAL.ID,
			name = pluginActions.ACCEPT_OVER_ORIGINAL.NAME,
		},
		dump = {
			id = pluginActions.ACCEPT_UNDER_FOLDER.ID,
			name = pluginActions.ACCEPT_UNDER_FOLDER.NAME,
		},
		dismiss = {
			id = pluginActions.DECLINE_CHANGE.ID,
			name = pluginActions.DECLINE_CHANGE.NAME,
		},
	}

	getActionDataFromResolveType = function(resolveType: resolveDiffType): { id: string, name: string }
		return resolveToActionMap[resolveType]
	end
end

local DiffSynchronizer = {}

DiffSynchronizer.diffsChanged = diffsChangedSignal

function DiffSynchronizer:init()
	initialized = true

	sessionFetchedConnection = SessionManager.workingSessionFetched:Connect(function(session)
		diffs = generateDiffsFromSession(session)

		currentWorkingSession = session

		diffsChangedSignal:Fire(diffs)
	end)
end

function DiffSynchronizer:getDiffs(): diffsType
    return diffs
end

function DiffSynchronizer:resolveDiffs(diffIds: { string }, resolveType: resolveDiffType)
	assertInitialization()

	local actionData = getActionDataFromResolveType(resolveType)
	recordedAction(function()
		for _, diffId in pairs(diffIds) do
			if resolveType == "override" then
				overrideDiff(diffId)
			elseif resolveType == "dump" then
				dumpDiff(diffId)
			end

            currentWorkingSession:removeInstanceData(diffId)
            diffs[diffId] = nil
		end
	end, actionData.id, actionData.name)

	diffsChangedSignal:Fire(diffs)
end

function DiffSynchronizer:cleanup()
	initialized = false

	diffsChangedSignal:DisconnectAll()
	sessionFetchedConnection:Disconnect()
end

return DiffSynchronizer
