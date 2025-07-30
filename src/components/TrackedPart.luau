local react = require(script.Parent.Parent.packages.react)
local studiocomponents = require(script.Parent.Parent.packages.studiocomponents)

local e = react.createElement

type trackedPartProps = {
	Name: string,
	OnActivated: () -> ()
}

function TrackedPart(props: trackedPartProps)
	return e(studiocomponents.Button, {
		Icon = {
			Image = "rbxassetid://103885201279057",
			Size = Vector2.new(16, 16),
		},
		Text = props.Name,
		OnActivated = props.OnActivated

	})
end

return TrackedPart
