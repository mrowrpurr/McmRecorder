scriptName McmRecorder extends Quest  

; TODO separate out an McmRecorderPrivate so this can become just a public API intended for integration

int property CurrentRecordingId auto
SKI_ConfigManager property skiConfigManager auto
Message property McmRecorder_Message_RunRecordingOrViewSteps auto
Message property McmRecorder_Message_SelectorNotFound auto
Form property McmRecorder_MessageText auto
string property CurrentlyInstalledVersion auto

McmRecorder function GetInstance() global
    return Quest.GetQuest("McmRecorder") as McmRecorder
endFunction

string function GetVersion() global
    return "1.0.3"
endFunction

function Log(string text) global
    ; Debug.Trace("[MCM Recorder] " + text)
endFunction

function LogContainer(string text, int jcontainer) global
    ; Log(text + ":\n" + ToJson(jcontainer))
endFunction

event OnInit()
    skiConfigManager = Quest.GetQuest("SKI_ConfigManagerInstance") as SKI_ConfigManager
    CurrentlyInstalledVersion = GetVersion()
endEvent

string function PathToRecordings() global
    return "Data/McmRecorder"
endFunction

string function PathToRecordingFolder(string recordingName) global
    return PathToRecordings() + "/" + FileSystemPathPart(recordingName)
endFunction

string function PathToStepFile(string recordingName, string stepName) global
    return PathToRecordings() + "/" + FileSystemPathPart(recordingName) + "/" + stepName + ".json"
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

string function JdbPathToCurrentlySkippingModName() global
    return ".mcmRecorder.playingRecording.modCurrentlySkipping"
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
    SetCurrentRecordingName(recordingName)
    SetCurrentRecordingModName("")
    ResetCurrentRecordingSteps()
    int metaFile = JMap.object()
    string authorName = Game.GetPlayer().GetActorBase().GetName()
    JMap.setStr(metaFile, "name", recordingName)    
    JMap.setStr(metaFile, "version", "1.0.0")
    JMap.setStr(metaFile, "author", authorName)
    JValue.writeToFile(metaFile, PathToRecordingFolder(recordingName) + ".json")
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
    int recordingStepNumber = JMap.allKeysPArray(JValue.readFromDirectory(recordingFolder)).Length
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
    if ! MiscUtil.FileExists(PathToRecordings())
        string[] ret
        return ret
    endIf

    string[] fileNames = JMap.allKeysPArray(JValue.readFromDirectory(PathToRecordings()))
    int i = 0
    while i < fileNames.Length
        fileNames[i] = StringUtil.Substring(fileNames[i], 0, StringUtil.Find(fileNames[i], ".json"))
        i += 1
    endWhile
    return fileNames
endFunction

int function GetRecordingInfo(string recordingName) global
    return JValue.ReadFromFile(PathToRecordingFolder(recordingName) + ".json")
endFunction

SKI_ConfigBase function GetMcmInstance(string modName) global
    McmRecorder recorder = GetInstance()
    int index = recorder.skiConfigManager.ModNames.Find(modName)
    return recorder.skiConfigManager.ModConfigs[index]
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

function SetCurrentPlayingRecordingModPageName(string pageName) global
    JDB.solveStrSetter(JdbPathToPlayingRecordingModPageName(), pageName , createMissingKeys = true)
endFunction

string function GetCurrentlySkippingModName() global
    return JDB.solveStr(JdbPathToCurrentlySkippingModName())
endFunction

function SetCurrentlySkippingModName(string modName) global
    JDB.solveStrSetter(JdbPathToCurrentlySkippingModName(), modName, createMissingKeys = true)
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
    Log("AddConfigOption " + modName + " " + pageName + " " + optionText + " " + optionStrValue)
    LogContainer("Added Config Option", option)
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

        if optionType == "clickable"
            if JMap.getStr(option, "type") == "toggle"
                JMap.setStr(mcmAction, "option", JMap.getStr(option, "text"))
                if JMap.getFlt(option, "fltValue") == 0
                    JMap.setStr(mcmAction, "toggle", "on")
                else
                    JMap.setStr(mcmAction, "toggle", "off")
                endIf
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

string[] function GetRecordingStepNames(string recordingName) global
    return JMap.allKeysPArray(JValue.readFromDirectory(PathToRecordingFolder(recordingName)))
endFunction

function PlayRecording(string recordingName, float waitTimeBetweenActions = 0.0) global
    SetCurrentPlayingRecordingModName("")
    SetCurrentPlayingRecordingModPageName("")

    SetIsPlayingRecording(true)

    int steps = JValue.readFromDirectory(PathToRecordingFolder(recordingName))
    JValue.retain(steps)

    string[] stepFiles = JMap.allKeysPArray(steps)

    Notification("Play " + recordingName + " (" + stepFiles.Length + " steps)")

    int fileIndex = 0
    while fileIndex < stepFiles.Length
        string filename = stepFiles[fileIndex]
        int recordingActions = JMap.getObj(steps, filename)
        JValue.retain(recordingActions)
        int actionCount = JArray.count(recordingActions)
        Notification(filename + " (" + (fileIndex + 1) + "/" + stepFiles.Length + ")")

        int i = 0
        while i < actionCount
            int recordingAction = JArray.getObj(recordingActions, i)
            PlayAction(recordingAction, StringUtil.Substring(filename, 0, StringUtil.Find(filename, ".json")))
            if waitTimeBetweenActions
                Utility.WaitMenuMode(waitTimeBetweenActions)
            endIf
            i += 1
        endWhile

        JValue.release(recordingActions)
        fileIndex += 1
    endWhile
    Debug.MessageBox("MCM recording " + recordingName + " has finished playing.")

    JValue.release(steps)
    SetIsPlayingRecording(false)
endFunction

function PlayStep(string recordingName, string stepName, float waitTimeBetweenActions = 0.0) global
    SetCurrentPlayingRecordingModName("")
    SetCurrentPlayingRecordingModPageName("")
    SetIsPlayingRecording(true) ; XXX is this used?

    int stepInfo = JValue.readFromFile(PathToStepFile(recordingName, StringUtil.Substring(stepName, 0, StringUtil.Find(stepName, ".json"))))
    
    JValue.retain(stepInfo)

    Notification("Playing step " + stepName + " of recording " + recordingName)
    
    int actionCount = JArray.count(stepInfo)
    int i = 0
    while i < actionCount
        int recordingAction = JArray.getObj(stepInfo, i)
        PlayAction(recordingAction, stepName)
        if waitTimeBetweenActions
            Utility.WaitMenuMode(waitTimeBetweenActions)
        endIf
        i += 1
    endWhile
    
    JValue.release(stepInfo)

    SetIsPlayingRecording(false)
endFunction

function PlayAction(int actionInfo, string stepName, bool promptOnFailures = true) global
    LogContainer("Run Action", actionInfo)

    string modName = JMap.getStr(actionInfo, "mod")
    string pageName = JMap.getStr(actionInfo, "page")

    string skippingModName = GetCurrentlySkippingModName()
    if skippingModName
        if modName == skippingModName
            return ; Skip!
        else
            SetCurrentlySkippingModName("")
        endIf
    endIf

    SKI_ConfigBase mcm = GetMcmInstance(modName)

    if ! mcm
        Debug.Trace("MCM recorder could not load MCM menu for " + modName)
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
            elseIf optionType == "toggle"
                string turnOnOrOff = JMap.getStr(actionInfo, "toggle")
                bool currentlyEnabledOnPage = JMap.getFlt(option, "fltValue") == 1
                if currentlyEnabledOnPage && turnOnOrOff == "off"
                    mcm.OnSelectST() ; Turn off
                elseIf (!currentlyEnabledOnPage) && turnOnOrOff == "on"
                    mcm.OnSelectST() ; Turn on
                endIf
            elseIf optionType == "text"
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
            elseIf optionType == "toggle"
                string turnOnOrOff = JMap.getStr(actionInfo, "toggle")
                bool currentlyEnabledOnPage = JMap.getFlt(option, "fltValue") == 1
                if currentlyEnabledOnPage && turnOnOrOff == "off"
                    mcm.OnOptionSelect(optionId) ; Turn off
                elseIf (!currentlyEnabledOnPage) && turnOnOrOff == "on"
                    mcm.OnOptionSelect(optionId) ; Turn on
                endIf
            elseIf optionType == "text"
                mcm.OnOptionSelect(optionId)
            endIf
        endIf
    elseIf promptOnFailures
        string response = GetUserResponseForNotFoundSelector(modName, pageName, selector)
        if response == "Try again"
            PlayAction(actionInfo, stepName, promptOnFailures)
        elseIf response == "Skip this mod"
            SetCurrentlySkippingModName(modName)
        endIf
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
    string filepath = PathToRecordings() + "/" + ".temp" + "/temp.json"
    JValue.writeToFile(jcontainer, filepath)
    return MiscUtil.ReadFromFile(filepath)
endFunction

string function GetUserResponseToRunRecording(string text)
    McmRecorder_MessageText.SetName(text)
    int response = McmRecorder_Message_RunRecordingOrViewSteps.Show()
    if response == 0
        return "Play Recording"
    elseIf response == 1
        return "View Steps"
    elseIf response == 2
        return "Add to Recording"
    elseIf response == 3
        return "Cancel"
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
    McmRecorder recorder = McmRecorder.GetInstance()
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

string function GetRecordingDescription(string recordingName) global
    int info = McmRecorder.GetRecordingInfo(recordingName)
    string[] stepNames = McmRecorder.GetRecordingStepNames(recordingName)

    string recordingDescription = recordingName
    if JMap.getStr(info, "version")
        recordingDescription += " (" + JMap.getStr(info, "version") + ")"
    endIf
    if JMap.getStr(info, "author")
        recordingDescription += "\n~ by " + JMap.getStr(info, "author") + " ~"
    endIf
    recordingDescription += "\nSteps: " + stepNames.Length
    
    return recordingDescription
endFunction
