local RunService = game:GetService("RunService")
local types = require(script.Parent.Parent.types)

return function(): types.pluginRuntime
	-- Must be in studio to run plugin
	if RunService:IsStudio() then
		if RunService:IsRunning() then
			-- NOTE: for now, the plugin will only sync changes made by the client, this is why we return other as the runtime if its running on the BuildTestServer.
			if RunService:IsClient() then
				return "studioPlayTestClient"
			else
				return "other"
			end
		else
			return "studioEditMode"
		end
	else
		return "other"
	end
end
