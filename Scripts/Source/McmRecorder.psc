scriptName McmRecorder extends Quest  

int property CurrentRecordingId auto
SKI_ConfigManager property skiConfigManager auto

McmRecorder function GetInstance() global
    return Game.GetFormFromFile(0x800, "McmRecorder.esp") as McmRecorder
endFunction

function Log(string text) global
    ; return ; Disable logging
    Debug.Trace("[MCM Recorder] " + text)
endFunction

function LogContainer(string text, int jcontainer) global
    Log(text + ":\n" + ToJson(jcontainer))
endFunction

event OnInit()
    skiConfigManager = Game.GetFormFromFile(0x802, "SkyUI_SE.esp") as SKI_ConfigManager
endEvent

string function PathToRecordings() global
    return "Data/McmRecorder"
endFunction

string function PathToRecordingFolder(string recordingName) global
    return PathToRecordings() + "/" + FileSystemPathPart(recordingName)
endFunction

string function JdbPathToCurrentRecordingName() global
    return ".mcmRecorder.currentRecording.recordingName"
endFunction

string function JdbPathToCurrentRecordingModName() global
    return ".mcmRecorder.currentRecording.currentModName"
endFunction

string function JdbPathToCurrentRecordingRecordingStep() global
    return ".mcmRecorder.currentRecording.currentModStep"
endFunction

string function JdbPathToMcmOptions() global
    return ".mcmRecorder.mcmOptions"
endFunction

string function JdbPathToModConfigurationOptionsForPage(string modName, string pageName) global
    return JdbPathToMcmOptions() + "." + JdbPathPart(modName) + "." + JdbPathPart(pageName)
endFunction

string function JdbPathToIsPlayingRecording() global
    return ".mcmRecorder.isPlayingRecording"
endFunction

string function JdbPathToPlayingRecordingModName() global
    return ".mcmRecorder.playingRecording.modName"
endFunction

string function JdbPathToPlayingRecordingModPageName() global
    return ".mcmRecorder.playingRecording.pageName"
endFunction

string function JdbPathPart(string part) global
    string[] parts = StringUtil.Split(part, ".")
    string sanitized = ""
    int i = 0
    while i < parts.Length
        if i == 0
            sanitized += parts[i]
        else
            sanitized += "_" + parts[i]
        endIf
        i += 1
    endWhile
    return sanitized
endFunction

string function FileSystemPathPart(string part) global
    string[] parts = StringUtil.Split(part, "/")
    string sanitized = ""
    int i = 0
    while i < parts.Length
        if i == 0
            sanitized += parts[i]
        else
            sanitized += "_" + parts[i]
        endIf
        i += 1
    endWhile
    parts = StringUtil.Split(sanitized, "\\")
    sanitized = ""
    i = 0
    while i < parts.Length
        if i == 0
            sanitized += parts[i]
        else
            sanitized += "_" + parts[i]
        endIf
        i += 1
    endWhile
    return sanitized
endFunction

function BeginRecording(string recordingName) global
    int recordingSteps = JArray.object()
    SetCurrentRecordingName(recordingName)
    SetCurrentRecordingModName("")
    ResetCurrentRecordingSteps()
endFunction

function StopRecording() global
    SetCurrentRecordingName("")
endFunction

string function GetCurrentRecordingName() global
    return JDB.solveStr(JdbPathToCurrentRecordingName())
endFunction

function SetCurrentRecordingName(string recodingName) global
    JDB.solveStrSetter(JdbPathToCurrentRecordingName(), recodingName, createMissingKeys = true)
endFunction

string function GetCurrentRecordingModName() global
    return JDB.solveStr(JdbPathToCurrentRecordingMOdName())
endFunction

function SetCurrentRecordingModName(string modName) global
    JDB.solveStrSetter(JdbPathToCurrentRecordingModName(), modName , createMissingKeys = true)
endFunction

int function GetCurrentRecordingSteps() global
    return JDB.solveObj(JdbPathToCurrentRecordingRecordingStep())
endFunction

function SetCurrentRecordingSteps(int stepInfo) global
    JDB.solveObjSetter(JdbPathToCurrentRecordingRecordingStep(), stepInfo, createMissingKeys = true)
endFunction

function ResetCurrentRecordingSteps() global
    SetCurrentRecordingSteps(JArray.object())
endFunction

string function GetFileNameForRecordingAction(string recordingName, string modName) global
    string recordingFolder = PathToRecordingFolder(recordingName)
    int recordingStepNumber = MiscUtil.FilesInFolder(recordingFolder).Length
    if modName != GetCurrentRecordingModName()
        recordingStepNumber += 1
        SetCurrentRecordingModName(modName)
    endIf
    string filenameNumericPrefix = recordingStepNumber
    while StringUtil.GetLength(filenameNumericPrefix) < 4
        filenameNumericPrefix = "0" + filenameNumericPrefix
    endWhile
    return PathToRecordingFolder(recordingName) + "/" + filenameNumericPrefix + "_" + FileSystemPathPart(modName) + ".json"
endFunction

string[] function GetRecordingNames() global
    string[] fileNames = MiscUtil.FoldersInFolder(PathToRecordings())
    int i = 0
    while i < fileNames.Length
        fileNames[i] = StringUtil.Substring(fileNames[i], 0, StringUtil.Find(fileNames[i], ".json"))
        i += 1
    endWhile
    return fileNames
endFunction

SKI_ConfigBase function GetMcmInstance(string modName) global
    McmRecorder recorder = GetInstance()
    int index = recorder.skiConfigManager._modNames.Find(modName)
    return recorder.skiConfigManager._modConfigs[index]
endFunction

function SetIsPlayingRecording(bool running = true) global
    JDB.solveIntSetter(JdbPathToIsPlayingRecording(), running as int, createMissingKeys = true)
endFunction

bool function IsPlayingRecording() global
    return JDB.solveInt(JdbPathToIsPlayingRecording())
endFunction

bool function IsRecording() global
    return GetCurrentRecordingName()
endFunction

string function GetCurrentPlayingRecordingModName() global
    return JDB.solveStr(JdbPathToPlayingRecordingModName())
endFunction

function SetCurrentPlayingRecordingModName(string modName) global
    JDB.solveStrSetter(JdbPathToPlayingRecordingModName(), modName , createMissingKeys = true)
endFunction

string function GetCurrentPlayingRecordingModPageName() global
    return JDB.solveStr(JdbPathToPlayingRecordingModPageName())
endFunction

function SetCurrentPlayingRecordingModPageName(string pagename) global
    JDB.solveStrSetter(JdbPathToPlayingRecordingModPageName(), pageName , createMissingKeys = true)
endFunction

function Save(string recordingName, string modName) global
    JValue.writeToFile(GetCurrentRecordingSteps(), GetFileNameForRecordingAction(recordingName, modName))
endFunction

function AddConfigurationOption(string modName, string pageName, int optionId, string optionType, string optionText, string optionStrValue, float optionFltValue, string stateName) global
    int optionsOnModPageForType = GetModPageConfigurationOptionsByOptionType(modName, pageName, optionType)
    int option = JMap.object()
    JArray.addObj(optionsOnModPageForType, option)
    JMap.setObj(GetModPageConfigurationOptionsByOptionIds(modName, pageName), optionId, option)
    JMap.setInt(option, "id", optionId)
    JMap.setStr(option, "state", stateName)
    JMap.setStr(option, "type", optionType)
    JMap.setStr(option, "text", optionText)
    JMap.setStr(option, "strValue", optionStrValue)
    JMap.setFlt(option, "fltValue", optionFltValue)
    JValue.writeToFile(JDB.solveObj(".mcmRecorder"), "McmOptions.json")
    Log("AddConfigOption " + modName + " " + pageName + " " + optionText + " " + optionStrValue)
    ; LogContainer("Added Config Option", option)
endFunction

int function GetConfigurationOption(string modName, string pageName, int optionId) global
    return JMap.getObj(GetModPageConfigurationOptionsByOptionIds(modName, pageName), optionId)
endFunction

function ResetMcmOptions() global
    JDB.solveObjSetter(JdbPathToMcmOptions(), JMap.object(), createMissingKeys = true)
endFunction

int function GetModPageConfigurationOptions(string modName, string pageName) global
    if ! pageName
        pageName = "SKYUI_DEFAULT_PAGE"
    endIf
    int options = JDB.solveObj(JdbPathToModConfigurationOptionsForPage(modName, pageName))
    if ! options
        options = JMap.object()
        JDB.solveObjSetter(JdbPathToModConfigurationOptionsForPage(modName, pageName), options, createMissingKeys = true)
        JMap.setObj(options, "byId", JMap.object())
        JMap.setObj(options, "byType", JMap.object())
    endIf
    return options
endFunction

int function GetModPageConfigurationOptionsByOptionIds(string modName, string pageName) global
    return JMap.getObj(GetModPageConfigurationOptions(modName, pageName), "byId")
endFunction

int function GetModPageConfigurationOptionsByOptionTypes(string modName, string pageName) global
    return JMap.getObj(GetModPageConfigurationOptions(modName, pageName), "byType")
endFunction

int function GetModPageConfigurationOptionsByOptionType(string modName, string pageName, string optionType) global
    int byType = GetModPageConfigurationOptionsByOptionTypes(modName, pageName)
    int typeMap = JMap.getObj(byType, optionType)
    if ! typeMap
        typeMap = JArray.object()
        JMap.setObj(byType, optionType, typeMap)
    endIf
    return typeMap
endFunction

function RecordAction(SKI_ConfigBase mcm, string modName, string pageName, string optionType, int optionId, string stateName = "", bool recordFloatValue = false, bool recordStringValue = false, bool recordOptionType = false, float fltValue = -1.0, string strValue = "", string[] menuOptions = None) global
    if IsRecording() && modName != "MCM Recorder"
        if modName != GetCurrentRecordingModName()
            ResetCurrentRecordingSteps()
        endIf

        int option = GetConfigurationOption(modName, pageName, optionId)

        int mcmAction = JMap.object()
        JArray.addObj(GetCurrentRecordingSteps(), mcmAction)

        JMap.setStr(mcmAction, "mod", modName)

        if pageName != "SKYUI_DEFAULT_PAGE"
            JMap.setStr(mcmAction, "page", pageName)
        endIf

        if optionType == "clickable"
            if JMap.getStr(option, "type") == "toggle"
                JMap.setStr(mcmAction, "toggle", JMap.getStr(option, "text"))
            else
                if JMap.getStr(option, "text")
                    JMap.setStr(mcmAction, "click", JMap.getStr(option, "text"))
                else
                    JMap.setStr(mcmAction, "click", JMap.getStr(option, "strValue"))
                    JMap.setStr(mcmAction, "side", "right")
                endIf
            endIf
        elseIf optionType == "menu"
            JMap.setStr(mcmAction, "option", JMap.getStr(option, "text"))
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
            JMap.setStr(mcmAction, "option", JMap.getStr(option, "text"))
            JMap.setFlt(mcmAction, "slider", fltValue)
        elseIf optionType == "keymap"
            JMap.setStr(mcmAction, "option", JMap.getStr(option, "text"))
            JMap.setInt(mcmAction, "shortcut", fltValue as int)
        elseIf optionType == "color"
            JMap.setStr(mcmAction, "option", JMap.getStr(option, "text"))
            JMap.setInt(mcmAction, "color", fltValue as int)
        elseIf optionType == "input"
            JMap.setStr(mcmAction, "option", JMap.getStr(option, "text"))
            JMap.setStr(mcmAction, "text", strValue)
        else
            Debug.MessageBox("TODO: support " + optionType)
        endIf

        Save(GetCurrentRecordingName(), modName)
    endIf
endFunction

function Notification(string text) global
    Debug.Notification("[McmRecorder] " + text)
endFunction

function PlayRecording(string recordingName, float waitTimeBetweenActions = 0.5) global
    SetCurrentPlayingRecordingModName("")
    SetCurrentPlayingRecordingModPageName("")

    SetIsPlayingRecording(true)

    string[] stepFiles = MiscUtil.FilesInFolder(PathToRecordingFolder(recordingName))

    Notification("Play " + recordingName + " (" + stepFiles.Length + " steps)")

    int fileIndex = 0
    while fileIndex < stepFiles.Length
        string filename = stepFiles[fileIndex]
        int recordingActions = JValue.readFromFile(PathToRecordingFolder(recordingName) + "/" + filename)
        JValue.retain(recordingActions)
        int actionCount = JArray.count(recordingActions)
        Notification(filename + " (" + (fileIndex + 1) + "/" + stepFiles.Length + ")")

        int i = 0
        while i < actionCount
            int recordingAction = JArray.getObj(recordingActions, i)
            PlayAction(recordingAction, filename)
            if waitTimeBetweenActions
                Utility.WaitMenuMode(waitTimeBetweenActions)
            endIf
            i += 1
        endWhile

        JValue.release(recordingActions)
        fileIndex += 1
    endWhile
    Debug.MessageBox("MCM recording " + recordingName + " has finished playing.")

    SetIsPlayingRecording(false)
endFunction

function PlayAction(int actionInfo, string stepName) global
    LogContainer("Run Action", actionInfo)

    string modName = JMap.getStr(actionInfo, "mod")
    string pageName = JMap.getStr(actionInfo, "page")

    SKI_ConfigBase mcm = GetMcmInstance(modName)

    if ! mcm
        Debug.MessageBox("MCM recorder could not load MCM menu for " + modName + " for step " + stepName + " action: " + ToJson(actionInfo)) ; TODO turn into a LOG TRACE
        return
    endIf

    if modName != GetCurrentPlayingRecordingModName() || pageName != GetCurrentPlayingRecordingModPageName()
        RefreshMcmPage(mcm, pageName)
    endIf

    SetCurrentPlayingRecordingModName(modName)
    SetCurrentPlayingRecordingModPageName(pageName)

    string optionType
    string selector = JMap.getStr(actionInfo, "option")

    if JMap.hasKey(actionInfo, "click")
        optionType = "text"
        selector = JMap.getStr(actionInfo, "click")
    elseIf JMap.hasKey(actionInfo, "toggle")
        optionType = "toggle"
        selector = JMap.getStr(actionInfo, "toggle")
    elseIf JMap.hasKey(actionInfo, "choose")
        optionType = "menu"
    elseIf JMap.hasKey(actionInfo, "text")
        optionType = "input"
    elseIf JMap.hasKey(actionInfo, "shortcut")
        optionType = "keymap"
    elseIf JMap.hasKey(actionInfo, "color")
        optionType = "color"
    elseIf JMap.hasKey(actionInfo, "slider")
        optionType = "slider"
    else
        Debug.MessageBox("MCM recording step " + stepName + " has action of unknown or unsupported type: '" + optionType + "'\n" + ToJson(actionInfo))
        return
    endIf

    string wildcard = GetWildcardMatcher(selector)
    string side = JMap.getStr(actionInfo, "side", "left")
    string stateName = JMap.getStr(actionInfo, "state")
    
    float searchTimeout = JMap.getFlt(actionInfo, "timeout", 30.0) ; Default to wait for options to show up for a max of 30 seconds
    float searchInterval = JMap.getFlt(actionInfo, "interval", 0.5) ; Default to try twice per second
    float searchPageLoadTime = JMap.getFlt(actionInfo, "pageload", 5.0) ; Allow pages up to 5 seconds for an option to appear

    int option = FindOption(mcm, modName, pageName, optionType, selector, wildcard, side, searchTimeout, searchInterval, searchPageLoadTime)
    if option
        LogContainer("Found Option", option)
        if ! stateName
            stateName = JMap.getStr(option, "state")
        endIf
        int optionId = JMap.getInt(option, "id")
        if stateName
            string previousState = mcm.GetState()
            mcm.GotoState(stateName)
            if optionType == "menu"
                string menuItem = JMap.getStr(actionInfo, "choose")
                mcm.OnMenuOpenST()
                string[] menuOptions = mcm.MostRecentlyConfiguredMenuDialogOptions
                int itemIndex = menuOptions.Find(menuItem)
                if itemIndex == -1
                    Debug.MessageBox("Could not find " + menuItem + " menu item. Available options: " + menuOptions)
                else
                    mcm.OnMenuAcceptST(itemIndex)
                endIf
            elseIf optionType == "keymap"
                mcm.OnKeyMapChangeST(JMap.getFlt(actionInfo, "shortcut") as int, "", "")
            elseIf optionType == "color"
                mcm.OnColorAcceptST(JMap.getInt(actionInfo, "color"))
            elseIf optionType == "input"
                mcm.OnInputAcceptST(JMap.getStr(actionInfo, "text"))
            elseIf optionType == "slider"
                mcm.OnSliderAcceptST(JMap.getFlt(actionInfo, "slider"))
            elseIf optionType == "toggle" || optionType == "text"
                Log("On Select ST")
                mcm.OnSelectST()
            endIf
            mcm.GotoState(previousState)
        else
            if optionType == "menu"
                string menuItem = JMap.getStr(actionInfo, "choose")
                mcm.OnOptionMenuOpen(optionId)
                string[] menuOptions = mcm.MostRecentlyConfiguredMenuDialogOptions
                int itemIndex = menuOptions.Find(menuItem)
                if itemIndex == -1
                    Debug.MessageBox("Could not find " + menuItem + " menu item. Available options: " + menuOptions)
                else
                    mcm.OnOptionMenuAccept(optionId, itemIndex)
                endIf
            elseIf optionType == "slider"
                mcm.OnOptionSliderAccept(optionId, JMap.getFlt(actionInfo, "slider"))
            elseIf optionType == "keymap"
                mcm.OnOptionKeyMapChange(optionId, JMap.getFlt(actionInfo, "shortcut") as int, "", "")
            elseIf optionType == "color"
                mcm.OnOptionColorAccept(optionId, JMap.getInt(actionInfo, "color"))
            elseIf optionType == "input"
                mcm.OnOptionInputAccept(optionId, JMap.getStr(actionInfo, "text"))
            elseIf optionType == "toggle" || optionType == "text"
                Log("OnOptionSelect " + optionId)
                mcm.OnOptionSelect(optionId)
            endIf
        endIf
    else
        Debug.MessageBox("Could not find option " + optionType + " for " + modName + " " + pageName + " selector: '" + selector)
    endIf
endFunction

int function FindOption(SKI_ConfigBase mcm, string modName, string pageName, string optionType, string selector, string wildcard, string side, float searchTimeout, float searchInterval, float searchPageLoadTime) global
    int foundOption
    float startTime = Utility.GetCurrentRealTime()
    while (! foundOption) && (Utility.GetCurrentRealTime() - startTime) < searchTimeout
        foundOption = AttemptFindOption(mcm, modName, pageName, optionType, selector, wildcard, side, searchInterval, searchPageLoadTime)
        if ! foundOption ; Does this ever run?
            Notification(modName + ": " + pageName + " (search for " + selector + ")")
            Utility.WaitMenuMode(searchInterval)
        endIf
    endWhile
    return foundOption
endFunction

function RefreshMcmPage(SKI_ConfigBase mcm, string pageName) global
    ResetMcmOptions()
    mcm.CloseConfig()
    mcm.OpenConfig()
    mcm.SetPage(pageName, mcm.Pages.Find(pageName))
endFunction

int function AttemptFindOption(SKI_ConfigBase mcm, string modName, string pageName, string optionType, string selector, string wildcard, string side, float searchInterval, float searchPageLoadTime) global
    Log("Refresh Page " + modName + " " + pageName)

    float startTime = Utility.GetCurrentRealTime()
    while (Utility.GetCurrentRealTime() - startTime) < searchPageLoadTime
        int options = GetModPageConfigurationOptionsByOptionType(modName, pageName, optionType)
        int optionsCount = JArray.count(options)
        Log("Searching for option: " + modName + " " + pageName + " " + optionType + " " + selector)
        LogContainer("Options on this page", options)
        int i = 0
        while i < optionsCount
            int option = JArray.getObj(options, i)
            
            string optionText = JMap.getStr(option, "text")
            if side == "right"
                optionText = JMap.getStr(option, "strValue")
            endIf

            bool matches
            if wildcard
                matches = StringUtil.Find(optionText, wildcard) > -1
            else
                matches = optionText == selector
            endIf

            if matches
                return option
            endIf

            i += 1
        endWhile
        
        Utility.WaitMenuMode(searchInterval)

        RefreshMcmPage(mcm, pageName) ; Wasn't on the page! Let's refresh the page.

        if (Utility.GetCurrentRealTime() - startTime) >= 4 ; Every 4 seconds print an update
            Notification(modName + ": " + pageName + " (search for " + selector + ")")
        endIf
    endWhile

    return 0
endFunction

string function GetWildcardMatcher(string selector) global
    int strLength = StringUtil.GetLength(selector)
    if StringUtil.Substring(selector, 0, 1) == "*" && StringUtil.Substring(selector, strLength - 1, 1) == "*"
        return StringUtil.Substring(selector, 1, strLength - 2)
    else
        return ""
    endIf
endFunction

string function ToJson(int jcontainer) global
    ; return "LOGGING OBJECT SERIALIZATION"
    string filepath = PathToRecordings() + "/" + "temp.json"
    JValue.writeToFile(jcontainer, filepath)
    return MiscUtil.ReadFromFile(filepath)
endFunction
