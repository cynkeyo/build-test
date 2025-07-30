local HttpService = game:GetService("HttpService")

local constants = require(script.Parent.Parent.Parent.constants)
local types = require(script.Parent.Parent.Parent.types)

local CONSTANTS = constants

local sessionManager = {}

local currentPlugin: Plugin

local function getSessionKeyFromPlaceId(placeId: string): string
	return `{CONSTANTS.PLUGIN_SESSION_KEY}-{placeId}`
end

local function assertServerInitialization()
	assert(currentPlugin, "Plugin instance isn't loaded in the server.")
end

function sessionManager.init(plugin: Plugin)
	currentPlugin = plugin
end

function sessionManager.saveSessionToPlaceId(session: types.BuildTestSession, placeId: string)
	assertServerInitialization()

	local key = getSessionKeyFromPlaceId(placeId)

	currentPlugin:SetSetting(key, HttpService:JSONEncode(session))
end

function sessionManager.getSessionFromPlaceId(placeId: string): types.BuildTestSession
	assertServerInitialization()

	local key = getSessionKeyFromPlaceId(placeId)
	local session = currentPlugin:GetSetting(key)

	if session then
		return HttpService:JSONDecode(currentPlugin:GetSetting(key))
	else
		return session
	end
end

return sessionManager
