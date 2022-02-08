scriptName McmRecorder_MCM_Home_RecordingDetails hidden

function Render(McmRecorderMCM mcmMenu) global
    string recordingName = mcmMenu.CurrentlyViewingRecordingName
    mcmMenu.CurrentlyViewingRecordingName = "" ; <--- clear this so we don't always load this view :)

    mcmMenu.SetTitleText(recordingName)

    mcmMenu.AddTextOption("Selected Recording:", "", mcmMenu.OPTION_FLAG_DISABLED)
    mcmMenu.AddTextOption("", "PLAY RECORDING", mcmMenu.OPTION_FLAG_NONE)

    mcmMenu.AddTextOption("", recordingName, mcmMenu.OPTION_FLAG_DISABLED)
    mcmMenu.AddTextOption("", "DELETE RECORDING", mcmMenu.OPTION_FLAG_NONE)

    int recording = McmRecorder_Recording.Get(recordingName)
    string[] stepNames = McmRecorder_Recording.GetStepNames(recording)
    if stepNames
        mcmMenu.AddHeaderOption("Recording Steps", mcmMenu.OPTION_FLAG_NONE)
        mcmMenu.AddEmptyOption()

        int i = 0
        while i < stepNames.Length
            string stepName = stepNames[i]
            mcmMenu.AddTextOption("", stepName, mcmMenu.OPTION_FLAG_NONE)
            mcmMenu.AddMenuOption("", "Step Actions", mcmMenu.OPTION_FLAG_NONE)
            i += 1
        endWhile
    endIf
endFunction
