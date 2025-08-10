local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Selection = game:GetService("Selection")

local types = require(script.Parent.Parent.types)
local MInstance : types.MInstanceModule  = require(script.MInstance)
local constants = require(script.Parent.Parent.constants)
local goodsignal = require(script.Parent.Parent.packages[".pesde"]["stravant_goodsignal@0.3.0"].goodsignal)
local getRuntimeEnviroment = require(script.Parent.Parent.utils.getRuntimeEnviroment)
local recordedAction = require(script.Parent.Parent.utils.recordedAction)
local sessionManager = require(script.sessionManager)

local CONSTANTS = constants
local TRACK_PART_ACTION = CONSTANTS.PLUGIN_ACTIONS.TRACK_PART
local UNTRACK_PART_ACTION = CONSTANTS.PLUGIN_ACTIONS.UNTRACK_PART
local HIGHLIGHT_PART_ACTION = CONSTANTS.PLUGIN_ACTIONS.HIGHLIGHT_PART
local SERIALIZATION_SETTINGS = {
	IncludeDescendants = false,
	CompressSerializedData = true,
	EncodeInBase94 = true,
	AnnoyingConsolePrints = false,
	UseLegacySlowCompressor = false,
	IncludeAttributes = false,
	DisallowedProperties = nil
}

local DESERIALIZATION_SETTINGS = {
	IsDataCompressed = true,
	IsBase94Encoded = true,
	AnnoyingConsolePrints = false,
	IsCompressedWithLegacyCompressor = false,
	ProperlyDeserializeMeshParts = true,
	ParentInstanceWhileDeserializing = nil,
}

local currentPlugin: Plugin
local runtimeEnviroment: types.pluginRuntime
local sessionChangeFetcher: thread?

local buildTestServer = {}

buildTestServer.instanceTracked = nil :: RBXScriptSignal?
buildTestServer.instanceUntracked = nil :: RBXScriptSignal?

local function assertServerInitialization()
	assert(currentPlugin, "Plugin instance isn't loaded in the server.")
end

local function getTrackedInstances(): {Instance}
	return CollectionService:GetTagged(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)
end

local function fetchSessionChanges()
	local playtestSession = sessionManager.getSessionFromPlaceId(game.PlaceId)

	if playtestSession then
		recordedAction(function() 
			local trackedInstanceMap = {}

			for _, instance in pairs(getTrackedInstances()) do
				local trackId = instance:GetAttribute(CONSTANTS.PLUGIN_INSTANCE_ID_ATTRIBUTE)
				trackedInstanceMap[trackId] = instance
			end

			for trackId, serializedData in pairs(playtestSession) do
				local trackedInstance = trackedInstanceMap[trackId]
				local currentSerialization = MInstance.SerializeInstance(trackedInstance, SERIALIZATION_SETTINGS)

				if currentSerialization == serializedData then
					print("no changes made, skip serialization")
					continue
				end

				MInstance.DeserializeInstance(serializedData, DESERIALIZATION_SETTINGS, trackedInstance)
			end

			-- All changes to session done, set it to nil.
			sessionManager.saveSessionToPlaceId(nil, game.PlaceId)
		end, "ACCEPT_CHANGES", "Accept incoming changes")
	end
end

function buildTestServer.init(plugin: Plugin)
	currentPlugin = plugin
	runtimeEnviroment = getRuntimeEnviroment()

	buildTestServer.instanceTracked = CollectionService:GetInstanceAddedSignal(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)
	buildTestServer.instanceUntracked = CollectionService:GetInstanceRemovedSignal(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)

	sessionManager.init(plugin)

	if runtimeEnviroment == "studioEditMode" then
		sessionChangeFetcher = task.spawn(function()
			-- HACK: there isn't a better way to check if the player exited playtest mode so we have to continously
			-- fetch for changes in the session instead of relying in a signal per se
			-- TODO: create a setting that allows the user to change the fetcher interval

			while task.wait(1) do
				-- print("cycle complete")
				fetchSessionChanges()
			end
		end)
		-- studio runtime init
	elseif runtimeEnviroment == "studioPlayTestClient" then
		-- playtest client runtime init
	end
end

function buildTestServer.canTrackInstance(instance: Instance)
	return MInstance.IsClassCreatable(instance.ClassName)
end

function buildTestServer.filterValidInstances(instances: {Instance})
    local filteredInstances = {}

    for _, instance in pairs(instances) do
        for _, ignoreClass in pairs(CONSTANTS.PLUGIN_IGNORE_CLASSES) do
            if instance:IsA(ignoreClass) then
                continue
            end
        end

        table.insert(filteredInstances, instance)
    end

    return filteredInstances
end

function buildTestServer.trackInstances(instances: {Instance})
	recordedAction(function() 
        for _, instance in pairs(instances) do
            assert(buildTestServer.canTrackInstance(instance), `Can't track instance of class: {instance.ClassName}`)

            instance:AddTag(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)
            instance:SetAttribute(CONSTANTS.PLUGIN_INSTANCE_ID_ATTRIBUTE, HttpService:GenerateGUID(false))

            for _, descendant in pairs(instance:GetDescendants()) do
                if buildTestServer.canTrackInstance(descendant) then
                    descendant:AddTag(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)
                    descendant:SetAttribute(CONSTANTS.PLUGIN_INSTANCE_ID_ATTRIBUTE, HttpService:GenerateGUID(false))
                end
            end
        end
	end, TRACK_PART_ACTION.ID, TRACK_PART_ACTION.NAME)
end

function buildTestServer.untrackInstances(instances: {Instance})
	recordedAction(function() 
        for _, instance in pairs(instances) do
            instance:RemoveTag(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)
            instance:SetAttribute(CONSTANTS.PLUGIN_INSTANCE_ID_ATTRIBUTE, nil)

            for _, descendant in pairs(instance:GetDescendants()) do
                if buildTestServer.canTrackInstance(descendant) then
                    descendant:RemoveTag(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)
                    descendant:SetAttribute(CONSTANTS.PLUGIN_INSTANCE_ID_ATTRIBUTE, nil)
                end
            end
        end
	end, TRACK_PART_ACTION.ID, TRACK_PART_ACTION.NAME)
end

function buildTestServer.getTrackedInstances()
	return CollectionService:GetTagged(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)
end

function buildTestServer.getSelectedTrackedInstances()
	local selectedTrackedInstances = {}

	for _, instance in pairs(Selection:Get()) do
		if not instance:HasTag(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG) then
			continue
		end

		table.insert(selectedTrackedInstances, instance)
	end

  return selectedTrackedInstances
end

function buildTestServer.getInstanceTrackId(instance: Instance)
	return instance:GetAttribute(CONSTANTS.PLUGIN_INSTANCE_ID_ATTRIBUTE)
end

function buildTestServer.isInstanceTracked(instance: Instance): boolean
	return instance:HasTag(CONSTANTS.PLUGIN_TRACKED_INSTANCE_TAG)
end

function buildTestServer.close()
	buildTestServer.instanceTracked = nil
	buildTestServer.instanceUntracked = nil

	if runtimeEnviroment == "studioPlayTestClient" then
		local serializedState = {}

		for _, instance in pairs(getTrackedInstances()) do
			local trackId = instance:GetAttribute(CONSTANTS.PLUGIN_INSTANCE_ID_ATTRIBUTE)
			serializedState[trackId] = MInstance.SerializeInstance(instance, SERIALIZATION_SETTINGS)
		end

		sessionManager.saveSessionToPlaceId(serializedState, game.PlaceId)
		-- serialize playtest state
	elseif runtimeEnviroment == "studioEditMode" then
		if sessionChangeFetcher then
			task.cancel(sessionChangeFetcher)
		end
	end
end

return buildTestServer
