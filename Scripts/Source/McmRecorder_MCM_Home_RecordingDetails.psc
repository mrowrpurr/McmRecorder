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

        mcmMenu.RecordingDetails_StepActions_Options = Utility.CreateIntArray(stepNames.Length)
        mcmMenu.RecordingDetails_StepActions_StepNames = Utility.CreateStringArray(stepNames.Length)

        int i = 0
        while i < stepNames.Length
            string stepName = stepNames[i]
            mcmMenu.RecordingDetails_StepActions_StepNames[i] = stepName
            mcmMenu.AddTextOption("", stepName, mcmMenu.OPTION_FLAG_NONE)
            mcmMenu.RecordingDetails_StepActions_Options[i] = mcmMenu.AddMenuOption("", "Step Actions", mcmMenu.OPTION_FLAG_NONE)
            i += 1
        endWhile
    endIf
endFunction

function OnOptionMenuOpen(McmRecorderMCM mcmMenu, int optionId) global
    int stepIndex = mcmMenu.RecordingDetails_StepActions_Options.Find(optionId)
    string stepName = mcmMenu.RecordingDetails_StepActions_StepNames[stepIndex]
    string[] dialogOptions = new string[6]
    dialogOptions[0] = "[" + stepName + "]"
    dialogOptions[1] = "Run"
    dialogOptions[2] = "Delete"
    dialogOptions[3] = "Rename"
    dialogOptions[4] = "Add to"
    dialogOptions[5] = "Re-record"
    mcmMenu.SetMenuDialogOptions(dialogOptions)
endFunction
