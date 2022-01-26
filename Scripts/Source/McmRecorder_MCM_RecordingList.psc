scriptName McmRecorder_MCM_RecordingList hidden

function Render(McmRecorderMCM mcmMenu) global
    if McmRecorder_Recorder.IsRecording()
        mcmMenu.oid_RecordingList_Stop = mcmMenu.AddTextOption("Currently Recording!", "STOP RECORDING", mcmMenu.OPTION_FLAG_NONE)
        mcmMenu.AddTextOption(McmRecorder_Recorder.GetCurrentRecordingName(), "", mcmMenu.OPTION_FLAG_DISABLED)
    else
        if McmRecorder_VR.IsSkyrimVR()
            mcmMenu.oid_RecordingList_Record = mcmMenu.AddTextOption("Click to begin recording:", "BEGIN RECORDING", mcmMenu.OPTION_FLAG_NONE)
        else
            mcmMenu.oid_RecordingList_Record = mcmMenu.AddInputOption("Click to begin recording:", "BEGIN RECORDING", mcmMenu.OPTION_FLAG_NONE)
        endIf
        mcmMenu.AddEmptyOption()
    endIf
    mcmMenu.ListRecordings()
endFunction