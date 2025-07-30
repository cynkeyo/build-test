local ChangeHistoryService = game:GetService("ChangeHistoryService")

return function(
	action: () -> (), 
	actionId: string, 
	actionName: string, 
	finishType: Enum.FinishRecordingOperation?
)
	local finishType = finishType or Enum.FinishRecordingOperation.Append

	if ChangeHistoryService:IsRecordingInProgress(actionId) then
		ChangeHistoryService:FinishRecording(actionId, Enum.FinishRecordingOperation.Cancel)
	end

	local recording = ChangeHistoryService:TryBeginRecording(actionId, actionName)

	action()

	print(recording)

	ChangeHistoryService:FinishRecording(recording, finishType)
end
