local App = require(script.App)
local react = require(script.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)
local react_roblox = require(script.packages[".pesde"]["jsdotlua_react-roblox@17.2.1"]["react-roblox"])
local server = require(script.server)

local container = Instance.new("Folder")
container.Parent = game:GetService("CoreGui")

local root = react_roblox.createRoot(container)
local e = react.createElement

local App = e(App, {
    plugin = plugin
})

server.init(plugin)
root:render(App, { plugin = plugin })

plugin.Unloading:Connect(function()
	root:render(nil)
	server.close()
end)
