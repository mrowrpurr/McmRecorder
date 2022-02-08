scriptName McmRecorder_MCM_Home hidden

function Render(McmRecorderMCM mcmMenu) global
    if mcmMenu.CurrentlyViewingRecordingName
        McmRecorder_MCM_Home_RecordingDetails.Render(mcmMenu)
    elseIf McmRecorder_TopLevelPlayer.IsPaused()
        McmRecorder_MCM_Home_RecordingPaused.Render(mcmMenu)
    else
        McmRecorder_MCM_Home_RecordingList.Render(mcmMenu)
    endIf
endFunction
