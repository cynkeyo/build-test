local CollectionService = game:GetService("CollectionService")
--[[
--needs initialized:
--  - InstanceTracker
--
--Manages plugin sessions across modes, abstracting away implementation details from syncing up sessions
--]]

local InstanceSerializer = require(script.Parent.InstanceSerializer)
local InstanceTracker = require(script.Parent.InstanceTracker)
local goodsignal = require(script.Parent.Parent.packages[".pesde"]["stravant_goodsignal@0.3.0"].goodsignal)

local types = require(script.Parent.Parent.types)
local Session = require(script.Parent.Parent.utils.Session)
local getRuntimeEnviroment = require(script.Parent.Parent.utils.getRuntimeEnviroment)

local SESSION_KEY = "BUILD_TEST_SESSION"

local FETCH_TIME = 1

type workingSessionType = Session.ClassType?

local currentPlugin: Plugin
local initialized = false
local runtimeEnviroment: types.pluginRuntime = getRuntimeEnviroment()
local placeId = game.PlaceId
local sessionFetcher: thread
local currentWorkingSession: workingSessionType
local workingSessionFetched = goodsignal.new() :: goodsignal.Signal<Session.ClassType>

local function getSessionKeyFromPlaceId(placeId: number): string
	return `{SESSION_KEY}-{placeId}`
end

local function saveSession(session: Session.ClassType)
	currentPlugin:SetSetting(getSessionKeyFromPlaceId(placeId), session:serialize())
end

local function getSession(): Session.SerializedSession?
    return currentPlugin:GetSetting(getSessionKeyFromPlaceId(placeId))
end

local function fetchSession()
	local foundSession = getSession()
	if foundSession then
        -- steal the session away
        currentPlugin:SetSetting(getSessionKeyFromPlaceId(placeId), nil)

		local deserializedSession = Session.fromSerialization(foundSession)
		currentWorkingSession = deserializedSession

		workingSessionFetched:Fire(currentWorkingSession)
	end
end

local function assertInitialization()
    assert(initialized, "SessionManager is not initialized.")
end

local SessionManager = {}

SessionManager.workingSessionFetched = workingSessionFetched

function SessionManager:init(plugin: Plugin)
	currentPlugin = plugin

	sessionFetcher = task.spawn(function()
        -- Only fetch session if we are in edit mode to work on it
        if runtimeEnviroment ~= "studioEditMode" then
            return
        end

		while task.wait(FETCH_TIME) do
			fetchSession()
		end
	end)

    initialized = true
end

function SessionManager:getWorkingSession(): workingSessionType
    assertInitialization()

    return currentWorkingSession
end

function SessionManager:cleanup()
    assertInitialization()

    initialized = false
	workingSessionFetched:DisconnectAll()

    if runtimeEnviroment == "studioEditMode" then
        if currentWorkingSession then
            saveSession(currentWorkingSession)
        end
    elseif runtimeEnviroment == "studioPlayTestClient" then
        local newSession = Session.new()

        for _, instance in pairs(InstanceTracker:getTracked()) do
            local id = InstanceTracker.getTrackId(instance)
            newSession:addInstanceData(InstanceSerializer.serializeInstance(instance), id)
        end

        saveSession(newSession)
    end

	task.cancel(sessionFetcher)
end

return SessionManager
