scriptName McmRecorder_UI

function Notification(string text) global
    Debug.Notification("[McmRecorder] " + text)
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
    recorder.McmRecorder_MessageText.SetName(description)
    int response = recorder.McmRecorder_Message_SelectorNotFound.Show()
    if response == 0
        return "Continue"
    elseIf response == 1 
        return "Try again"
    elseIf response == 2
        return "Skip this mod"
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
        return "Try again"
    elseIf response == 1
        return "Skip this mod"
    endIf
endFunction