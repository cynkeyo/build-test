local react = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)

local MenuContext = react.createContext(nil :: PluginMenu?)
MenuContext.displayName = "PluginMenuContext"

return MenuContext
