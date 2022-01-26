scriptName McmRecorder_MCM_RecordingPaused hidden

function Render(McmRecorderMCM mcmMenu) global
    mcmMenu.SetCursorFillMode(mcmMenu.TOP_TO_BOTTOM)
    string pausedRecordingName = McmRecorder_Player.GetCurrentlyPlayingRecordingName()
    mcmMenu.AddHeaderOption("Recording currently paused", mcmMenu.OPTION_FLAG_NONE)
    mcmMenu.AddTextOption("Recording name:", "", mcmMenu.OPTION_FLAG_DISABLED)
    mcmMenu.AddTextOption(pausedRecordingName, "", mcmMenu.OPTION_FLAG_DISABLED)
    mcmMenu.oid_PausedRecording_Resume = mcmMenu.AddTextOption("", "RESUME RECORDING", mcmMenu.OPTION_FLAG_NONE)
    mcmMenu.oid_PausedRecording_Cancel = mcmMenu.AddTextOption("", "CANCEL RECORDING", mcmMenu.OPTION_FLAG_NONE)
endFunction

function OnOptionSelect(McmRecorderMCM mcmMenu, int optionId) global
    string pausedRecordingName = McmRecorder_Player.GetCurrentlyPlayingRecordingName()
    if optionId == mcmMenu.oid_PausedRecording_Resume
        Debug.MessageBox("Resuming recording " + pausedRecordingName + "\n\nClose MCM to continue")
        McmRecorder_Player.ResumeCurrentRecording()
    elseIf optionId == mcmMenu.oid_PausedRecording_Cancel
        McmRecorder_Player.CancelCurrentRecording()
        Debug.MessageBox("Canceled recording " + pausedRecordingName)
    endIf
    mcmMenu.ForcePageReset()
endFunction
