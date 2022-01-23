scriptName McmRecorder_UI

function Notification(string text) global
    if McmRecorder_Config.ShowNotifications()
        Debug.Notification("[McmRecorder] " + text)
    endIf
endFunction

function MessageBox(string text) global
    if McmRecorder_Config.ShowMessageBoxes()
        Debug.MessageBox(text)
    endIf
endFunction

string function Options_Continue() global
    return "Continue"
endFunction

string function Options_TryAgain() global
    return "Try again"
endFunction

string function Options_SkipThisMod() global
    return "Skip this mod"
endFunction

function FinishedMessage(string recordingName) global
    int recording = McmRecorder_RecordingInfo.Get(recordingName)
    string finishedMessage = McmRecorder_RecordingInfo.GetCompleteMessage(recording)
    if ! finishedMessage
        finishedMessage = recordingName + " has finished playing."
    endIf
    MessageBox(finishedMessage)
endFunction

function WelcomeMessage(string recordingName) global
    int recording = McmRecorder_RecordingInfo.Get(recordingName)
    string welcomeMessage = McmRecorder_RecordingInfo.GetWelcomeMessage(recording)
    if welcomeMessage
        MessageBox(welcomeMessage)
    endIf
endFunction

function OpenSystemMenuDuringRecordingMessage(string recordingName) global
    int stepCount = JMap.count(McmRecorder_Player.GetCurrentlyPlayingSteps())
    int stepIndex = McmRecorder_Player.GetCurrentlyPlayingStepIndex()
    string stepName = McmRecorder_Player.GetCurrentlyPlayingStepFilename()
    string text = recordingName + " currently in progress."
    text += "\n\nCurrently playing step " + stepName + " ("+ (stepIndex + 1) + "/" + stepCount + ")"
    text += "\n\nPlease exit the menu to allow this recording to continue."
    text += "\n\nYou will also have an option to pause or cancel the recording."
    MessageBox(text)

    McmRecorder recorder = McmRecorder.GetMcmRecorderInstance()
    
    text = recordingName + " currently in progress."
    text += "\n\nCurrently playing step " + stepName + " ("+ (stepIndex + 1) + "/" + stepCount + ")"
    text += "\n\nWould you like to continue, pause, or cancel playing this recording?"
    SetMessageBoxText(text)

    int continue = 0
    int pause = 1
    int cancel = 2
    int result = recorder.McmRecorder_Message_PauseOrCancelEtc.Show()
    if result == continue
        ; Nothing, just continue!
    elseIf result == pause
        Debug.MessageBox("PAUSE")
    elseIf result == cancel
        Debug.MessageBox("CANCEL")
    endIf
endFunction

string function GetUserResponseForNotFoundSelector(string modName, string pageName, string selector) global
    string description = "Could not find MCM option:\n\nMod name: " + modName
    if pageName
        description += "\nPage name: " + pageName
    endIf
    description += "\nField name: " + selector
    description += "\n\nWhich of the following would you like to do?"
    description += "\n- Continue this mod and move on to the next MCM field"
    description += "\n- Try finding this MCM field again"
    description += "\n- Skip this mod and move on to configuring the next one"
    McmRecorder recorder = McmRecorder.GetMcmRecorderInstance()
    SetMessageBoxText(description)
    int response = recorder.McmRecorder_Message_SelectorNotFound.Show()
    if response == 0
        return Options_Continue()
    elseIf response == 1 
        return Options_TryAgain()
    elseIf response == 2
        return Options_SkipThisMod()
    endIf
endFunction

string function GetUserResponseForNotFoundMod(string modName) global
    string description = "Could not find MCM\n\nMod name: " + modName
    description += "\n\nWhich of the following would you like to do?"
    description += "\n- Try waiting longer for this mod to become available"
    description += "\n- Skip this mod and move on to configuring the next one"
    McmRecorder recorder = McmRecorder.GetMcmRecorderInstance()
    recorder.McmRecorder_MessageText.SetName(description)
    int response = recorder.McmRecorder_Message_ModNotFound.Show()
    if response == 0
        return Options_TryAgain()
    elseIf response == 1
        return Options_SkipThisMod()
    endIf
endFunction

function ShowMcmHelperRecordingWarning() global
    Debug.MessageBox("This Mod Configuration Menu cannot be recorded because it was created using MCM Helper.\n\nYou can still manually create a recording for this mod.\n\nFor instructions on creating a recording, visit the MCM Recorder NexusMods description page.")
endFunction

function SetMessageBoxText(string text) global
    McmRecorder.GetMcmRecorderInstance().McmRecorder_MessageText.SetName(text)
endFunction
