scriptName McmRecorder_MCM_VrGestures hidden

string function PageName() global
    return "VR Gestures"
endFunction

function Render(McmRecorderMCM mcmMenu) global
    string[] recordingNames = McmRecorder_Files.GetRecordingNames() ; --> recordingNames
    if recordingNames.Length && ((! McmRecorder_Recorder.IsRecording()) || recordingNames.Length > 1)
        mcmMenu.SetCursorFillMode(mcmMenu.TOP_TO_BOTTOM)
        mcmMenu.AddTextOption("Choose MCM Recordings", "", mcmMenu.OPTION_FLAG_DISABLED)
        mcmMenu.AddTextOption("These will become available as VRIK Gestures", "", mcmMenu.OPTION_FLAG_DISABLED)
        mcmMenu.AddTextOption("which can be configured via the VRIK MCM", "", mcmMenu.OPTION_FLAG_DISABLED)
        mcmMenu.AddEmptyOption()
        mcmMenu.SetCursorFillMode(mcmMenu.LEFT_TO_RIGHT)
        mcmMenu.oid_VrGestures_RecordingToggles = Utility.CreateIntArray(recordingNames.Length)
        mcmMenu.VrGestures_RecordingNames = Utility.CreateStringArray(recordingNames.Length)
        int i = 0
        while i < recordingNames.Length
            string recordingName = recordingNames[i]
            if recordingName != McmRecorder_Recorder.GetCurrentRecordingName()
                string[] stepNames = McmRecorder_Files.GetRecordingStepFilenames(recordingName)
                int recordingInfo = McmRecorder_Recording.Get(recordingName)
                if ! McmRecorder_Recording.IsHidden(recordingInfo)
                    mcmMenu.oid_VrGestures_RecordingToggles[i] = mcmMenu.AddToggleOption(recordingName, isGesture, mcmMenu.OPTION_FLAG_NONE)
                    mcmMenu.VrGestures_RecordingNames[i] = recordingName
                    bool isGesture = McmRecorder_Recording.IsVrGesture(recordingInfo)
                    string stepCountText
                    if stepNames.Length == 1
                        stepCountText = stepNames.Length + " mod"
                    else
                        stepCountText = stepNames.Length + " mods"
                    endIf

                    int totalActionCount = McmRecorder_Recording.GetTotalActionCount(recordingInfo)
                    string actionCountText
                    if totalActionCount == 1
                        actionCountText = totalActionCount + " configured option"
                    else
                        actionCountText = totalActionCount + " configured options"
                    endIf

                    mcmMenu.AddTextOption(actionCountText, stepCountText, mcmMenu.OPTION_FLAG_DISABLED)
                endIf
            endIf
            i += 1
        endWhile
    else
        mcmMenu.AddTextOption("There are no recordingNames", "", mcmMenu.OPTION_FLAG_DISABLED)
    endIf
endFunction

function OnOptionSelect(McmRecorderMCM mcmMenu, int optionId) global
    int recordingIndex = mcmMenu.oid_VrGestures_RecordingToggles.Find(optionId)
    string recordingName = mcmMenu.VrGestures_RecordingNames[recordingIndex]
    int recording = McmRecorder_Recording.Get(recordingName)
    bool isGesture = McmRecorder_Recording.IsVrGesture(recording)
    if isGesture
        McmRecorder_Recording.SetIsVrGesture(recording, false)
        mcmMenu.SetToggleOptionValue(optionId, false, false)
        McmRecorder_VR.UnregisterVrikGestureForRecording(recordingName)
    else
        McmRecorder_Recording.SetIsVrGesture(recording, true)
        mcmMenu.SetToggleOptionValue(optionId, true, false)
        McmRecorder_VR.RegisterVrikGestureForRecording(recordingName)
    endIf
endFunction
