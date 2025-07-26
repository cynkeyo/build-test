local react = require(script.Parent.Parent.packages.react)

local MenuContext = react.createContext(nil :: PluginMenu?)
MenuContext.displayName = "PluginMenuContext"

return MenuContext
