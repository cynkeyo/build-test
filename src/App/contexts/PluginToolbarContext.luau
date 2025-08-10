local React = require(script.Parent.Parent.Parent.packages[".pesde"]["jsdotlua_react-reconciler@17.2.1"].react)

local toolbarContext = React.createContext(nil :: PluginToolbar?)
toolbarContext.displayName = "PluginToolbarContext"

return toolbarContext
