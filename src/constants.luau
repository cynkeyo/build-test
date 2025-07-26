local pesde = require(script.Parent.pesde)

return {
	PLUGIN_NAME = "Build Test",
	PLUGIN_ID = "Build Test",
	PLUGIN_VERSION = pesde.version,
	PLUGIN_MENUS = {
		SELECTED_TRACKED_PART = {
			ID = "SELECTED_TRACKED_PART",
			TITLE = "Selected tracked part",
			ICON = ""
		}
	},
	PLUGIN_ACTIONS = {
		HIGHLIGHT_PART = {
			ID = "HIGHLIGHT_PART",
			TEXT = "Highlight Part",
			STATUS_TIP = "Highlights the Selected Part(s)",
			ICON_NAME = "rbxassetid://131319291327248",
			ALLOW_BINDING = false
		},
		UNTRACK_PART = {
			ID = "UNTRACK_PART",
			TEXT = "Remove Part from Build Test",
			STATUS_TIP = "Removes the Part(s) from the Build Test Tracker",
			ICON_NAME = "rbxassetid://78931432174335",
			ALLOW_BINDING = true
		},
		TRACK_PART = {
			ID = "TRACK_PART",
			TEXT = "Add Part to Build Test",
			STATUS_TIP = "Adds the Part(s) to the Build Test Tracker",
			ICON_NAME = "rbxassetid://74738063772202",
			ALLOW_BINDING = true
		},
	}
}
