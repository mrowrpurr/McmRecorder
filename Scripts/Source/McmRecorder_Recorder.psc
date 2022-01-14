scriptName McmRecorder_Recorder hidden
{Responsible for recording actions in Mod Configuration Menus}

function RecordAction(SKI_ConfigBase mcm, string modName, string pageName, string optionType, int optionId, string stateName = "", bool recordFloatValue = false, bool recordStringValue = false, bool recordOptionType = false, float fltValue = -1.0, string strValue = "", string[] menuOptions = None) global
    if McmRecorder.IsRecording() && modName != "MCM Recorder"
        if modName != GetCurrentRecordingModName()
            ResetCurrentRecordingSteps()
        endIf

        int option = McmRecorder_McmFields.GetConfigurationOptionById(modName, pageName, optionId)

        if ! option
            Debug.MessageBox("[McmRecorder] Problem! You clicked on an MCM field which we were not able to detect.")
            Debug.Notification("[McmRecorder] Problem! You clicked on an MCM field which we were not able to detect.")
            return
        endIf

        int mcmAction = JMap.object()
        JArray.addObj(GetCurrentRecordingSteps(), mcmAction)

        JMap.setStr(mcmAction, "mod", modName)

        if pageName != "SKYUI_DEFAULT_PAGE"
            JMap.setStr(mcmAction, "page", pageName)
        endIf

        string selector = JMap.getStr(option, "text")

        ; How many items on this page have the same 'selector'?
        int selectorIndex = McmRecorder_McmFields.GetSelectorIndex(modName, pageName, optionType, selector, optionId, stateName)
        if selectorIndex > -1
            JMap.setInt(mcmAction, "index", selectorIndex)
        endIf

        if optionType == "clickable"
            if JMap.getStr(option, "type") == "toggle"
                JMap.setStr(mcmAction, "option", selector)
                if JMap.getFlt(option, "fltValue") == 0
                    JMap.setStr(mcmAction, "toggle", "on")
                else
                    JMap.setStr(mcmAction, "toggle", "off")
                endIf
            else
                if selector
                    JMap.setStr(mcmAction, "click", selector)
                else
                    JMap.setStr(mcmAction, "click", JMap.getStr(option, "strValue"))
                    JMap.setStr(mcmAction, "side", "right")
                endIf
            endIf
        elseIf optionType == "menu"
            JMap.setStr(mcmAction, "option", selector)
            if stateName
                string previousState = mcm.GetState()
                mcm.GotoState(stateName)
                mcm.OnMenuOpenST()
                string selectedOptionText = menuOptions[fltValue as int]
                JMap.setStr(mcmAction, "choose", selectedOptionText)
                mcm.GotoState(previousState)
            else
                mcm.OnOptionMenuOpen(optionId)
                string selectedOptionText = menuOptions[fltValue as int]
                JMap.setStr(mcmAction, "choose", selectedOptionText)
            endIf
        elseIf optionType == "slider"
            JMap.setStr(mcmAction, "option", selector)
            JMap.setFlt(mcmAction, "slider", fltValue)
        elseIf optionType == "keymap"
            JMap.setStr(mcmAction, "option", selector)
            JMap.setInt(mcmAction, "shortcut", fltValue as int)
        elseIf optionType == "color"
            JMap.setStr(mcmAction, "option", selector)
            JMap.setInt(mcmAction, "color", fltValue as int)
        elseIf optionType == "input"
            JMap.setStr(mcmAction, "option", selector)
            JMap.setStr(mcmAction, "text", strValue)
        else
            Debug.MessageBox("TODO: support " + optionType)
        endIf

        McmRecorder_RecordingFiles.Save(GetCurrentRecordingName(), modName)
    endIf
endFunction

function BeginRecording(string recordingName) global
    SetCurrentRecordingName(recordingName)
    SetCurrentRecordingModName("")
    ResetCurrentRecordingSteps()
    int metaFile = JMap.object()
    string authorName = Game.GetPlayer().GetActorBase().GetName()
    JMap.setStr(metaFile, "name", recordingName)    
    JMap.setStr(metaFile, "version", "1.0.0")
    JMap.setStr(metaFile, "author", authorName)
    McmRecorder_RecordingFiles.WriteMetafile(recordingName, metaFile)
endFunction

function ContinueRecording(string recordingName) global
    SetCurrentRecordingName(recordingName)
    SetCurrentRecordingModName("")
    ResetCurrentRecordingSteps()
endFunction

function StopRecording() global
    SetCurrentRecordingName("")
endFunction

string function GetCurrentRecordingName() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_CurrentRecordingName())
endFunction

function SetCurrentRecordingName(string recodingName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_CurrentRecordingName(), recodingName, createMissingKeys = true)
endFunction

string function GetCurrentRecordingModName() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_CurrentRecordingMOdName())
endFunction

function SetCurrentRecordingModName(string modName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_CurrentRecordingModName(), modName , createMissingKeys = true)
endFunction

int function GetCurrentRecordingSteps() global
    return JDB.solveObj(McmRecorder_JDB.JdbPath_CurrentRecordingRecordingStep())
endFunction

function SetCurrentRecordingSteps(int stepInfo) global
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_CurrentRecordingRecordingStep(), stepInfo, createMissingKeys = true)
endFunction

function ResetCurrentRecordingSteps() global
    SetCurrentRecordingSteps(JArray.object())
endFunction
