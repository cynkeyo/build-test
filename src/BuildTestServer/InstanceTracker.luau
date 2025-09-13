--[[
--Plugin BuildTestServer sub-module responsible for tracking instances managed by the plugin
--Tags are used to persist track data from edit mode to playtest mode
--]]

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")

local goodsignal = require(script.Parent.Parent.packages[".pesde"]["stravant_goodsignal@0.3.0"].goodsignal)

local recordedAction = require(script.Parent.Parent.utils.recordedAction)
local MInstance = require(script.Parent.MInstance)
local constants = require(script.Parent.Parent.constants)
local actions = constants.PLUGIN_ACTIONS

local TRACK_TAG = "BUILD_TEST_TRACKED_INSTANCE"
local TRACK_ID = "BUILD_TEST_INSTANCE_ID"

local INCLUDE_DESCENDANTS = true

local initialized = false
local trackedInstancesArray: { Instance } = {} --keep order for explorer state
local trackedInstancesMap: { [string]: Instance } = {} --O(1) indexing
local trackedChangedSignal = goodsignal.new() :: goodsignal.Signal<{ Instance }>
local taggedAddedConnection
local taggedRemovedConnection

local function canTrackInstance(instance: Instance): boolean
	return MInstance.IsClassCreatable(instance.ClassName)
end

local function getInstanceTrackId(instance: Instance)
	return instance:GetAttribute(TRACK_ID) :: string?
end

local function trackInstance(instance: Instance)
	assert(canTrackInstance(instance), "Can't track instance.")

	local trackId = HttpService:GenerateGUID(false)

	instance:AddTag(TRACK_TAG)
	instance:SetAttribute(TRACK_ID, trackId)

	trackedInstancesMap[trackId] = instance
    table.insert(trackedInstancesArray, instance)
end

local function untrackInstance(instance: Instance)
	local trackId = getInstanceTrackId(instance)

	instance:RemoveTag(TRACK_TAG)
	instance:SetAttribute(TRACK_ID, nil)

	trackedInstancesMap[trackId] = nil
    table.remove(trackedInstancesArray, table.find(trackedInstancesArray, instance))
end

local function isInstanceTracked(instance: Instance)
	local trackId = getInstanceTrackId(instance)

	return trackedInstancesMap[trackId] ~= nil
end

local function assertInitialization()
	assert(initialized, "InstanceTracker is not initialized.")
end

local InstanceTracker = {}

InstanceTracker.trackChanged = trackedChangedSignal

function InstanceTracker.getTrackId(instance)
	return getInstanceTrackId(instance)
end

function InstanceTracker.filterValidInstances(instances: { Instance })
	local filtered = {}
    for _, instance in pairs(instances) do
        if not canTrackInstance(instance) then
            continue
        end

        table.insert(filtered, instance)
    end

    return filtered
end

function InstanceTracker:init()
    -- fetch persisted tracked instances
    for _, instance in pairs(CollectionService:GetTagged(TRACK_TAG)) do
        local trackId = getInstanceTrackId(instance)

        trackedInstancesMap[trackId] = instance
        table.insert(trackedInstancesArray, instance)
    end

	taggedAddedConnection = CollectionService:GetInstanceAddedSignal(TRACK_TAG):Connect(function(instance)
		local trackId = getInstanceTrackId(instance)

		-- don't allow the user to manage the plugin tag
		if not trackId then
			warn(`{instance} is tagged without a valid trackId.`)
			warn("If you added the tag manually, adding the tag manually does not work.")

			instance:RemoveTag(TRACK_TAG)

			return
		end

        -- instance just got added now but isn't tracked, track it manually
        if trackedInstancesMap[trackId] == nil then
            trackedInstancesMap[trackId] = instance
            table.insert(trackedInstancesArray, instance)

            trackedChangedSignal:Fire(trackedInstancesArray)

            return
        end

		-- This means a tracked instace got cloned, thus, carrying over the same track data
        -- Just remove the persistent track data
		if trackedInstancesMap[trackId] ~= instance then
            instance:RemoveTag(TRACK_TAG)
            instance:SetAttribute(TRACK_ID, nil)

            return
		end
	end)
    taggedRemovedConnection = CollectionService:GetInstanceRemovedSignal(TRACK_TAG):Connect(function(instance)
        -- this will ensure undo actions also fall under control
        table.remove(trackedInstancesArray, table.find(trackedInstancesArray, instance))
        for id, trackedInstance in pairs(trackedInstancesMap) do
            if trackedInstance == instance then
                trackedInstancesMap[id] = nil
            end
        end
    end)

	initialized = true
end

function InstanceTracker:isTracked(instance: Instance)
	return isInstanceTracked(instance)
end

function InstanceTracker:track(instances: { Instance })
	assertInitialization()

	recordedAction(function()
		for _, instance in pairs(instances) do
			trackInstance(instance)

			if not INCLUDE_DESCENDANTS then
				continue
			end

			for _, descendant in pairs(instance:GetDescendants()) do
				trackInstance(descendant)
			end
		end
	end, actions.TRACK_PART.ID, actions.TRACK_PART.NAME)

	trackedChangedSignal:Fire(trackedInstancesArray)
end

function InstanceTracker:untrack(instances: { Instance })
	assertInitialization()

	recordedAction(function()
		for _, instance in pairs(instances) do
			untrackInstance(instance)

			if not INCLUDE_DESCENDANTS then
				continue
			end

			for _, descendant in pairs(instance:GetDescendants()) do
				untrackInstance(descendant)
			end
		end
	end, actions.UNTRACK_PART.ID, actions.UNTRACK_PART.NAME)

	trackedChangedSignal:Fire(trackedInstancesArray)
end

function InstanceTracker:canTrackInstance(instance: Instance)
	return canTrackInstance(instance)
end

function InstanceTracker:getFromTrackId(trackId: string): Instance?
	assertInitialization()

	return trackedInstancesMap[trackId]
end

function InstanceTracker:getTracked()
	assertInitialization()

	return trackedInstancesArray
end

function InstanceTracker:getSelectedTracked()
	assertInitialization()

	local selectedTrackedInstances = {}

	for _, instance in pairs(Selection:Get()) do
		if not isInstanceTracked(instance) then
			continue
		end

		table.insert(selectedTrackedInstances, instance)
	end

	return selectedTrackedInstances
end

function InstanceTracker:cleanup()
	initialized = false
	taggedAddedConnection:Disconnect()
	taggedRemovedConnection:Disconnect()
	trackedChangedSignal:DisconnectAll()
end

return InstanceTracker
