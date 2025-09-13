local initialized = false
local dumpFolder: Folder

local Session = require(script.Parent.Parent.utils.Session)
local formatDate = require(script.Parent.Parent.utils.formatDate)

local DUMP_FOLDER_DIRECTORY = game:GetService("ServerStorage")
local DUMP_FOLDER_NAME = "BuildTestDump"

local function assertInitialization()
	assert(initialized, "DumpFolderManager isn't initialized.")
end

local function getFolderNameFromSession(session: Session.ClassType)
    return `dump-{formatDate(session:getCreationDate())}`
end

local function getSessionDumpFromSession(session: Session.ClassType)
    return dumpFolder:FindFirstChild(getFolderNameFromSession(session))
end

local DumpFolderManager = {}

function DumpFolderManager:init()
    initialized = true

    local foundDumpFolder = DUMP_FOLDER_DIRECTORY:FindFirstChild(DUMP_FOLDER_NAME)

    if not foundDumpFolder then
        local folder = Instance.new("Folder")
        folder.Name = DUMP_FOLDER_NAME
        folder.Parent = DUMP_FOLDER_DIRECTORY

        dumpFolder = folder
    else
        dumpFolder = foundDumpFolder
    end
end

function DumpFolderManager:getSessionDumpFromSession(session: Session.ClassType): Folder?
    local sessionDumpFolder = getSessionDumpFromSession(session)

    if not sessionDumpFolder then
        local newDumpFolder = Instance.new("Folder")
        newDumpFolder.Name = getFolderNameFromSession(session)
        newDumpFolder.Parent = dumpFolder

        sessionDumpFolder = newDumpFolder
    end

    return sessionDumpFolder
end

function DumpFolderManager:cleanup()
    initialized = false
end

return DumpFolderManager
