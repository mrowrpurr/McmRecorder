scriptName McmRecorder_MCM_Home_RecordingList hidden

function Render(McmRecorderMCM mcmMenu) global
    McmRecorder_RecordingsFolder.Reload()

    if McmRecorder_Recorder.IsRecording()
        mcmMenu.oid_Home_Stop = mcmMenu.AddTextOption("Currently Recording!", "STOP RECORDING", mcmMenu.OPTION_FLAG_NONE)
        mcmMenu.AddEmptyOption()
        mcmMenu.AddEmptyOption()
        mcmMenu.AddEmptyOption()
        mcmMenu.AddTextOption("Recording: ", "", mcmMenu.OPTION_FLAG_DISABLED)
        mcmMenu.AddEmptyOption()
        mcmMenu.AddTextOption("", McmRecorder_Recorder.GetCurrentRecordingName(), mcmMenu.OPTION_FLAG_DISABLED)
        mcmMenu.AddEmptyOption()
    else
        if McmRecorder_VR.IsSkyrimVR()
            mcmMenu.oid_Home_Record = mcmMenu.AddTextOption("Click to begin recording:", "BEGIN RECORDING", mcmMenu.OPTION_FLAG_NONE)
        else
            mcmMenu.oid_Home_Record = mcmMenu.AddInputOption("Click to begin recording:", "BEGIN RECORDING", mcmMenu.OPTION_FLAG_NONE)
        endIf
        mcmMenu.AddEmptyOption()
    endIf

    string[] recordingNames = McmRecorder_RecordingsFolder.GetRecordingNames()
    
    if recordingNames.Length && ((! McmRecorder_Recorder.IsRecording()) || recordingNames.Length > 1)
        mcmMenu.AddEmptyOption()
        mcmMenu.AddEmptyOption()
        int flagOption = mcmMenu.OPTION_FLAG_NONE
        if McmRecorder_Recorder.IsRecording()
            mcmMenu.AddTextOption("All recordings:", "", mcmMenu.OPTION_FLAG_DISABLED)
            flagOption = mcmMenu.OPTION_FLAG_DISABLED
        else
            mcmMenu.AddTextOption("Choose a recording to play:", "", mcmMenu.OPTION_FLAG_DISABLED)
        endIf
        mcmMenu.AddEmptyOption()

        mcmMenu.RecordingList_RecordingTextOptions = Utility.CreateIntArray(recordingNames.Length)
        mcmMenu.RecordingList_RecordingNames = Utility.CreateStringArray(recordingNames.Length)

        int i = 0
        while i < recordingNames.Length
            string recordingName = recordingNames[i]
            if recordingName != McmRecorder_Recorder.GetCurrentRecordingName()
                int recording = McmRecorder_Recording.Get(recordingName)
                string[] stepNames = McmRecorder_Recording.GetStepNames(recording)
                int recordingInfo = McmRecorder_Recording.Get(recordingName)
                if ! McmRecorder_Recording.IsHidden(recordingInfo)
                    mcmMenu.RecordingList_RecordingTextOptions[i] = mcmMenu.AddTextOption("", recordingName, flagOption)
                    mcmMenu.RecordingList_RecordingNames[i] = recordingName

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
    endIf
endFunction

function OnOptionSelect(McmRecorderMCM mcmMenu, int optionId) global
    ; [Stop]
    if McmRecorder_Recorder.IsRecording() && optionId == mcmMenu.oid_Home_Stop
        McmRecorder_Recorder.StopRecording()
        mcmMenu.ForcePageReset()
    ; [Record] 
    elseIf McmRecorder_VR.IsSkyrimVR() && (! McmRecorder_Recorder.IsRecording()) && optionId == mcmMenu.oid_Home_Record
        McmRecorder_Recorder.BeginRecording(McmRecorder_Recording.GetRandomRecordingName())
        mcmMenu.ForcePageReset()
    ; [Click on Recording]
    else
        int recordingIndex = mcmMenu.RecordingList_RecordingTextOptions.Find(optionId)
        string recordingName = mcmMenu.RecordingList_RecordingNames[recordingIndex]
        mcmMenu.RecordingDetails_CurrentRecordingName = recordingName
        mcmMenu.SetPage("Recording Details", 2) ; <--- change this, just testing
        ; PromptToRunRecordingOrPreviewSteps(mcmMenu, recordingName)
    endIf
endFunction

function OnOptionInputAccept(McmRecorderMCM mcmMenu, int optionId, string text) global
    McmRecorder_Recorder.BeginRecording(text)
    mcmMenu.ForcePageReset()
    Debug.MessageBox("Recording Started!\n\nYou can now interact with MCM menus and all interactions will be recorded.\n\nWhen you are finished, return to this page to stop the recording (or quit the game).\n\nRecordings are saved in simple text files inside of Data\\McmRecorder\\ which you can edit to tweak your recording without completely re-recording it :)")
endFunction

function OnOptionInputOpen(McmRecorderMCM mcmMenu, int optionId) global
    if optionId == mcmMenu.oid_Home_Record
        mcmMenu.SetInputDialogStartText(McmRecorder_Recording.GetRandomRecordingName())
    endIf
endFunction

; XXX clean me up and extract some bits to UI
function PromptToRunRecordingOrPreviewSteps(McmRecorderMCM mcmMenu, string recordingName) global
    int recordingInfo = McmRecorder_Recording.Get(recordingName)
    string recordingDescription = McmRecorder_Recording.GetDescriptionText(recordingInfo)
    bool confirmation = true

    ; The ShowMessage prompt can not be interacted with via SkyrimVR so we simply show a prompt - not a confirmation dialog
    if ! McmRecorder_VR.IsSkyrimVR()
        confirmation = mcmMenu.ShowMessage(recordingDescription + "\n\nClose the MCM to continue\n\nYou will be prompted to play this recording\n\nYou will also be able to preview all recording steps or play individual one\n\nYou will also be given the opportunity to continue the recording\n\nWould you like to continue?", "No", "Yes", "Cancel")
        if confirmation
            Debug.MessageBox("Close the MCM to continue")
        endIf
    endIf

    if confirmation
        string[] stepNames = McmRecorder_Files.GetRecordingStepFilenames(recordingName)
        string text = recordingDescription + "\n"
        int i = 0
        while i < stepNames.Length && i < 11
            if i == 10
                text += "\n- ..."
            else
                text += "\n- " + StringUtil.Substring(stepNames[i], 0, StringUtil.Find(stepNames[i], ".json"))
            endIf
            i += 1
        endWhile
        text += "\n\nWould you like to play this recording?"

        McmRecorder recorder = McmRecorder.GetMcmRecorderInstance()

        ; Inlined to extract method later
        recorder.McmRecorder_MessageText.SetName(text)
        
        int responseId = Recorder.McmRecorder_Message_RunRecordingOrViewSteps.Show()
        string response
        if responseId == 0
            response = "Play Recording"
        elseIf responseId == 1
            response = "View Steps"
        elseIf responseId == 2
            response = "Add to Recording"
        elseIf responseId == 3
            response = "Cancel"
        endIf

        if response == "Play Recording"
            McmRecorder_TopLevelPlayer.PlayByName(recordingName)
        elseIf response == "View Steps"
            ShowStepSelectionUI(recordingName, stepNames)
        elseIf response == "Add to Recording"
            McmRecorder_Recorder.ContinueRecording(recordingName)
            Debug.MessageBox("Recording has been restarted!\n\nYou can now interact with MCM menus and all interactions will be recorded.\n\nWhen you are finished, return to the MCM Recorder mod configuration menu to stop the recording (or quit the game).\n\nRecordings are saved in simple text files inside of Data\\McmRecorder\\ which you can edit to tweak your recording without completely re-recording it :)")
        endIf
    endIf
endFunction

function ShowStepSelectionUI(string recordingName, string[] stepNames) global
    UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
    menu.AddEntryItem("[" + recordingName + "]")
    menu.AddEntryItem(" ")

    int i = 0
    while i < stepNames.Length
        string stepName = stepNames[i]
        menu.AddEntryItem(stepName)
        i += 1
    endWhile

    menu.OpenMenu()

    int selection = menu.GetResultInt()

    if selection < 2 ; Go Back
        ; TODO open the previous prompt! This isn't working...
        ; PromptToRunRecordingOrPreviewSteps(recordingName)
    else
        int stepIndex = selection - 2 ; Subtract the top 3 entry items
        string stepName = stepNames[stepIndex]
        
        ; TODO TODO TODO FIXME
        ; McmRecorder_Player.PlayStep(recordingName, stepName)
        Debug.MessageBox("TODO FIXME!")

        Debug.MessageBox("MCM recording " + recordingName + " step " + StringUtil.Substring(stepName, 0, StringUtil.Find(stepName, ".json")) + " has finished playing.")
    endIf
endFunction