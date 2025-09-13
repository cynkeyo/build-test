local DiffSynchronizer = require(script.DiffSynchronizer)
local DumpFolderManager = require(script.DumpFolderManager)
local InstanceTracker = require(script.InstanceTracker)
local SessionManager = require(script.SessionManager)

local plugin: Plugin
local initialized = false

local function assertInitialization()
	assert(initialized, "BuildTestServer isn't initialized.")
end

local BuildTestServer = {}

BuildTestServer.InstanceTracker = InstanceTracker
BuildTestServer.DiffSynchronizer = DiffSynchronizer

function BuildTestServer:init(plugin: Plugin)
    plugin = plugin

    InstanceTracker:init()
    SessionManager:init(plugin)
    DumpFolderManager:init()
    DiffSynchronizer:init()

    initialized = true
end

function BuildTestServer:close()
    assertInitialization()

    DiffSynchronizer:cleanup()
    DumpFolderManager:cleanup()
    SessionManager:cleanup()
    InstanceTracker:cleanup()

    initialized = false
end

return BuildTestServer
