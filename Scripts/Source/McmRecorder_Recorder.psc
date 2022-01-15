scriptName McmRecorder_Recorder hidden
{Responsible for recording actions in Mod Configuration Menus}

bool function IsRecording() global
    return GetCurrentRecordingName()
endFunction

function RecordAction(SKI_ConfigBase mcm, string modName, string pageName, string optionType, int optionId, string stateName = "", bool recordFloatValue = false, bool recordStringValue = false, bool recordOptionType = false, float fltValue = -1.0, string strValue = "", string[] menuOptions = None) global
    if IsRecording() && modName != "MCM Recorder"
        if modName != GetCurrentRecordingModName()
            ResetCurrentRecordingSteps()
        endIf

        int option = McmRecorder_McmFields.GetConfigurationOptionById(modName, pageName, optionId)

        if ! option
            McmRecorder_Logging.ConsoleOut("Could not get configuration option for " + modName + " " + pageName + " optionId " + optionId)
            ; McmRecorder_Logging.DumpAll()
            Debug.MessageBox("[McmRecorder] Problem! You clicked on an MCM field which we were not able to detect.")
            Debug.Notification("[McmRecorder] Problem! You clicked on an MCM field which we were not able to detect.")
            return
        endIf

        if optionType == "menu" && fltValue == -1
            return ; The menu was opened but then closed without choosing an option. We don't reproduce this behavior.
        endIf

        int mcmAction = JMap.object()
        JArray.addObj(GetCurrentRecordingSteps(), mcmAction)

        JMap.setStr(mcmAction, "mod", modName)

        if pageName != "SKYUI_DEFAULT_PAGE"
            JMap.setStr(mcmAction, "page", pageName)
        endIf

        string selector = JMap.getStr(option, "text")

        ; How many items on this page have the same 'selector'?
        int selectorIndex = McmRecorder_McmFields.GetSelectorIndex(modName, pageName, optionId)
        if selectorIndex > -1
            JMap.setInt(mcmAction, "index", selectorIndex)
        endIf

        string debugPrefix = "[Record Action] " + modName
        if pageName
            debugPrefix += ": " + pageName
        endIf
        debugPrefix += " (" + selector + ")"
        if selectorIndex > -1
            debugPrefix += " [" + selectorIndex + "]"
        endIf

        if optionType == "clickable"
            if JMap.getStr(option, "type") == "toggle"
                JMap.setStr(mcmAction, "option", selector)
                if JMap.getFlt(option, "fltValue") == 0
                    JMap.setStr(mcmAction, "toggle", "on")
                    McmRecorder_Logging.ConsoleOut(debugPrefix + " on")
                else
                    JMap.setStr(mcmAction, "toggle", "off")
                    McmRecorder_Logging.ConsoleOut(debugPrefix + " off")
                endIf
            else
                if selector
                    JMap.setStr(mcmAction, "click", selector)
                    McmRecorder_Logging.ConsoleOut(debugPrefix + " click")
                else
                    JMap.setStr(mcmAction, "click", JMap.getStr(option, "strValue"))
                    JMap.setStr(mcmAction, "side", "right")
                    McmRecorder_Logging.ConsoleOut(debugPrefix + " click (right)")
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
                McmRecorder_Logging.ConsoleOut(debugPrefix + " choose '" + selectedOptionText + "'")
            else
                mcm.OnOptionMenuOpen(optionId)
                string selectedOptionText = menuOptions[fltValue as int]
                JMap.setStr(mcmAction, "choose", selectedOptionText)
                McmRecorder_Logging.ConsoleOut(debugPrefix + " choose '" + selectedOptionText + "'")
            endIf
        elseIf optionType == "slider"
            JMap.setStr(mcmAction, "option", selector)
            JMap.setFlt(mcmAction, "slider", fltValue)
            McmRecorder_Logging.ConsoleOut(debugPrefix + " slider " + fltValue)
        elseIf optionType == "keymap"
            JMap.setStr(mcmAction, "option", selector)
            JMap.setInt(mcmAction, "shortcut", fltValue as int)
            McmRecorder_Logging.ConsoleOut(debugPrefix + " shortcut " + fltValue as int)
        elseIf optionType == "color"
            JMap.setStr(mcmAction, "option", selector)
            JMap.setInt(mcmAction, "color", fltValue as int)
            McmRecorder_Logging.ConsoleOut(debugPrefix + " color " + fltValue as int)
        elseIf optionType == "input"
            JMap.setStr(mcmAction, "option", selector)
            JMap.setStr(mcmAction, "text", strValue)
            McmRecorder_Logging.ConsoleOut(debugPrefix + " input '" + strValue + "'")
        endIf

        McmRecorder_RecordingFiles.SaveCurrentRecording(GetCurrentRecordingName(), modName)
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
    JMap.setStr(metaFile, "autorun", "false")
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
