local react = require(script.Parent.Parent.Parent.packages.react)

function EditMode()
	return react.createElement("TextLabel", {
		Text = "asdasdasd",
		Size = UDim2.fromOffset(100, 100)
	})
end


return EditMode
