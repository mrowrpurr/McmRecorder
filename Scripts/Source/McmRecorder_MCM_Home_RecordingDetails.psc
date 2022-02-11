scriptName McmRecorder_MCM_Home_RecordingDetails hidden

function Render(McmRecorderMCM mcmMenu) global
    string recordingName = mcmMenu.RecordingDetails_CurrentlyViewingRecordingName
    mcmMenu.ShouldRenderRecordingDetails = false ; <--- clear this so we don't always load this view :)

    mcmMenu.SetTitleText(recordingName)

    mcmMenu.AddTextOption("Selected Recording:", "", mcmMenu.OPTION_FLAG_DISABLED)
    mcmMenu.RecordingDetails_Recording_Play = mcmMenu.AddTextOption("", "PLAY RECORDING", mcmMenu.OPTION_FLAG_NONE)

    mcmMenu.AddTextOption("", recordingName, mcmMenu.OPTION_FLAG_DISABLED)
    mcmMenu.RecordingDetails_RecordingOptions_Menu = mcmMenu.AddMenuOption("", "OPTIONS", mcmMenu.OPTION_FLAG_NONE)

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
            mcmMenu.RecordingDetails_StepActions_Options[i] = mcmMenu.AddMenuOption(stepName, "", mcmMenu.OPTION_FLAG_NONE)
            i += 1
        endWhile
    endIf
endFunction

function OnOptionMenuOpen(McmRecorderMCM mcmMenu, int optionId) global
    if optionId == mcmMenu.RecordingDetails_RecordingOptions_Menu
        mcmMenu.SetMenuDialogOptions(RecordingMenuOptions())
    else
        mcmMenu.SetMenuDialogOptions(StepMenuOptions())
    endIf
endFunction

function OnOptionMenuAccept(McmRecorderMCM mcmMenu, int optionId, int index) global
    if index == 1 ; Run Step

    elseIf index == 2 ; Run Recording (starting here)

    elseIf index == 3 ; Delete Step

    elseIf index == 5 ; Add to Step

    elseIf index == 6 ; Re-record Step

    endIf
endFunction

string[] function RecordingMenuOptions() global
    string[] dialogOptions = new string[2]
    dialogOptions[0] = "Add steps to Recording"
    dialogOptions[1] = "Delete Recording"
    return dialogOptions
endFunction

string[] function StepMenuOptions() global
    string[] dialogOptions = new string[5]
    dialogOptions[0] = "Run step"
    dialogOptions[1] = "Run recording (starting at this step)"
    dialogOptions[2] = "Delete step"
    dialogOptions[3] = "Add to step"
    dialogOptions[4] = "Re-record step"
    return dialogOptions
endFunction

function StepOption_RunStep() global
endFunction

function StepOption_RunRecordingStartingAtStep() global
endFunction

function StepOption_DeleteStep() global
endFunction

function StepOption_RenameStep() global
endFunction

function StepOption_AddToStep() global
endFunction

function StepOption_ReRecordStep() global
endFunction
