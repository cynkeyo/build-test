local function isShift(keyCode: Enum.KeyCode)
	return keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.RightShift
end

local function isControl(keyCode: Enum.KeyCode)
	return keyCode == Enum.KeyCode.LeftControl or keyCode == Enum.KeyCode.RightControl
end

return function(inputObject: InputObject): "shift" | "control" | nil
	local keyCode = inputObject.KeyCode

	if isShift(keyCode) then
		return "shift"
	elseif isControl(keyCode) then
		return "control"
	end

	return
end
