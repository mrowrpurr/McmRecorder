scriptName McmRecorder_Player hidden
{Responsible for playback of recordings or can trigger individual actions}

bool function IsPlayingRecording() global
    return JDB.solveInt(McmRecorder_JDB.JdbPath_IsPlayingRecording())
endFunction

function PlayRecording(string recordingName, float waitTimeBetweenActions = 0.0, float mcmLoadWaitTime = 0.0) global
    ClearModsPlayed()
    SetCurrentPlayingRecordingModName("")
    SetCurrentPlayingRecordingModPageName("")

    SetIsPlayingRecording(true)

    int steps = McmRecorder_RecordingFiles.GetAllStepsForRecording(recordingName)
    JValue.retain(steps)

    string[] stepFiles = JMap.allKeysPArray(steps)

    McmRecorder_UI.Notification("Play " + recordingName + " (" + stepFiles.Length + " steps)")

    int fileIndex = 0
    while fileIndex < stepFiles.Length
        string filename = stepFiles[fileIndex]
        int recordingActions = JMap.getObj(steps, filename)
        JValue.retain(recordingActions)
        int actionCount = JArray.count(recordingActions)
        McmRecorder_UI.Notification(filename + " (" + (fileIndex + 1) + "/" + stepFiles.Length + ")")

        int i = 0
        while i < actionCount
            int recordingAction = JArray.getObj(recordingActions, i)
            PlayAction(recordingAction, StringUtil.Substring(filename, 0, StringUtil.Find(filename, ".json")), mcmLoadWaitTime = mcmLoadWaitTime)
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

    int stepInfo = McmRecorder_RecordingFiles.GetRecordingStep(recordingName, stepName)
    
    JValue.retain(stepInfo)

    McmRecorder_UI.Notification("Playing step " + stepName + " of recording " + recordingName)
    
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

function PlayAction(int actionInfo, string stepName, bool promptOnFailures = true, float mcmLoadWaitTime = 10.0) global
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

    SKI_ConfigBase mcm = McmRecorder.GetMcmInstance(modName)

    if (! mcm) && mcmLoadWaitTime
        McmRecorder_Logging.ConsoleOut("[Play Action] MCM not loaded: " + modName + " (waiting...)")
        float startTime = Utility.GetCurrentRealTime()
        float lastNotification = startTime
        while (! mcm) && (Utility.GetCurrentRealTime() - startTime) < mcmLoadWaitTime
            float now = Utility.GetCurrentRealTime()
            if (now - lastNotification) >= 5.0 ; Make configurable, 5 secs waiting for MCM to load
                lastNotification = now
                McmRecorder_UI.Notification("Waiting for " + modName + " MCM to load")
                McmRecorder_Logging.ConsoleOut("[Play Action] MCM not loaded: " + modName + " (waiting...)")
            endIf
            Utility.WaitMenuMode(1.0) ; hard coded for now
            mcm = McmRecorder.GetMcmInstance(modName)
        endWhile
        if ! mcm
            if promptOnFailures
                string result = McmRecorder_UI.GetUserResponseForNotFoundMod(modName)
                if result == "Try again"
                    PlayAction(actionInfo, stepName, promptOnFailures, mcmLoadWaitTime)
                elseIf result == "Skip this mod"
                    SetCurrentlySkippingModName(modName)
                    return
                endIf
            else
                SetCurrentlySkippingModName(modName)
                return
            endIf
            return
        endIf
    endIf

    if ! mcm
        Debug.Trace("MCM recorder could not load MCM menu for " + modName)
        return
    endIf

    if modName != GetCurrentPlayingRecordingModName() || pageName != GetCurrentPlayingRecordingModPageName()
        RefreshMcmPage(mcm, modName, pageName)
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
        Debug.MessageBox("MCM recording step " + stepName + " has action of unknown or unsupported type: '" + optionType + "'\n" + McmRecorder_Logging.ToJson(actionInfo))
        return
    endIf

    string wildcard = McmRecorder_McmFields.GetWildcardMatcher(selector)
    string side = JMap.getStr(actionInfo, "side", "left")
    string stateName = JMap.getStr(actionInfo, "state")
    int index = JMap.getInt(actionInfo, "index", -1)

    string debugPrefix = "[Play Action] " + modName
    if pageName
        debugPrefix += ": " + pageName
    endIf
    debugPrefix += " (" + selector + ")"
    if index > -1
        debugPrefix += " [" + index + "]"
    endIf

    float searchTimeout = JMap.getFlt(actionInfo, "timeout", 30.0) ; Default to wait for options to show up for a max of 30 seconds
    float searchInterval = JMap.getFlt(actionInfo, "interval", 0.5) ; Default to try twice per second
    float searchPageLoadTime = JMap.getFlt(actionInfo, "pageload", 5.0) ; Allow pages up to 5 seconds for an option to appear

    int option = FindOption(mcm, modName, pageName, optionType, selector, wildcard, index, side, searchTimeout, searchInterval, searchPageLoadTime)

    if option
        if ! stateName
            stateName = JMap.getStr(option, "state")
        endIf
        int optionId = JMap.getInt(option, "id")
        if stateName
            string previousState = mcm.GetState()
            mcm.GotoState(stateName)
            if optionType == "menu"
                string menuItem = JMap.getStr(actionInfo, "choose")
                McmRecorder_Logging.ConsoleOut(debugPrefix + " choose '" + menuItem + "'")
                mcm.OnMenuOpenST()
                string[] menuOptions = mcm.MostRecentlyConfiguredMenuDialogOptions
                int itemIndex = menuOptions.Find(menuItem)
                if itemIndex == -1
                    Debug.MessageBox("Could not find " + menuItem + " menu item. Available options: " + menuOptions)
                else
                    mcm.OnMenuAcceptST(itemIndex)
                endIf
            elseIf optionType == "keymap"
                int shortcut = JMap.getFlt(actionInfo, "shortcut") as int
                McmRecorder_Logging.ConsoleOut(debugPrefix + " shortcut " + shortcut)
                mcm.OnKeyMapChangeST(shortcut, "", "")
            elseIf optionType == "color"
                int colorCode = JMap.getInt(actionInfo, "color")
                McmRecorder_Logging.ConsoleOut(debugPrefix + " color " + colorCode)
                mcm.OnColorAcceptST(colorCode)
            elseIf optionType == "input"
                string inputValue = JMap.getStr(actionInfo, "text")
                McmRecorder_Logging.ConsoleOut(debugPrefix + " input '" + inputValue + "'")
                mcm.OnInputAcceptST(inputValue)
            elseIf optionType == "slider"
                float sliderValue = sliderValue
                McmRecorder_Logging.ConsoleOut(debugPrefix + " slider " + sliderValue)
                mcm.OnSliderAcceptST(JMap.getFlt(actionInfo, "slider"))
            elseIf optionType == "toggle"
                string turnOnOrOff = JMap.getStr(actionInfo, "toggle")
                bool currentlyEnabledOnPage = JMap.getFlt(option, "fltValue") == 1
                if currentlyEnabledOnPage && turnOnOrOff == "off"
                    McmRecorder_Logging.ConsoleOut(debugPrefix + " toggle off")
                    mcm.OnSelectST() ; Turn off
                elseIf (!currentlyEnabledOnPage) && turnOnOrOff == "on"
                    McmRecorder_Logging.ConsoleOut(debugPrefix + " toggle on")
                    mcm.OnSelectST() ; Turn on
                endIf
            elseIf optionType == "text"
                McmRecorder_Logging.ConsoleOut(debugPrefix + " click")
                mcm.OnSelectST()
            endIf
            mcm.GotoState(previousState)
        else
            if optionType == "menu"
                string menuItem = JMap.getStr(actionInfo, "choose")
                McmRecorder_Logging.ConsoleOut(debugPrefix + " choose '" + menuItem + "'")
                mcm.OnOptionMenuOpen(optionId)
                string[] menuOptions = mcm.MostRecentlyConfiguredMenuDialogOptions
                int itemIndex = menuOptions.Find(menuItem)
                if itemIndex == -1
                    Debug.MessageBox("Could not find " + menuItem + " menu item. Available options: " + menuOptions)
                else
                    mcm.OnOptionMenuAccept(optionId, itemIndex)
                endIf
            elseIf optionType == "slider"
                float sliderValue = JMap.getFlt(actionInfo, "slider")
                McmRecorder_Logging.ConsoleOut(debugPrefix + " slider " + sliderValue)
                mcm.OnOptionSliderAccept(optionId, sliderValue)
            elseIf optionType == "keymap"
                int shortcut = JMap.getInt(actionInfo, "shortcut")
                McmRecorder_Logging.ConsoleOut(debugPrefix + " shortcut " + shortcut)
                mcm.OnOptionKeyMapChange(optionId, shortcut, "", "")
            elseIf optionType == "color"
                int colorCode = JMap.getInt(actionInfo, "color")
                McmRecorder_Logging.ConsoleOut(debugPrefix + " color " + colorCode)
                mcm.OnOptionColorAccept(optionId, colorCode)
            elseIf optionType == "input"
                string inputValue = JMap.getStr(actionInfo, "text")
                McmRecorder_Logging.ConsoleOut(debugPrefix + " input '" + inputValue + "'")
                mcm.OnOptionInputAccept(optionId, inputValue)
            elseIf optionType == "toggle"
                string turnOnOrOff = JMap.getStr(actionInfo, "toggle")
                bool currentlyEnabledOnPage = JMap.getFlt(option, "fltValue") == 1
                if currentlyEnabledOnPage && turnOnOrOff == "off"
                    McmRecorder_Logging.ConsoleOut(debugPrefix + " toggle off")
                    mcm.OnOptionSelect(optionId) ; Turn off
                elseIf (!currentlyEnabledOnPage) && turnOnOrOff == "on"
                    McmRecorder_Logging.ConsoleOut(debugPrefix + " toggle on")
                    mcm.OnOptionSelect(optionId) ; Turn on
                endIf
            elseIf optionType == "text"
                McmRecorder_Logging.ConsoleOut(debugPrefix + " click")
                mcm.OnOptionSelect(optionId)
            endIf
        endIf
    elseIf promptOnFailures
        string response = McmRecorder_UI.GetUserResponseForNotFoundSelector(modName, pageName, selector)
        if response == "Try again"
            PlayAction(actionInfo, stepName, promptOnFailures)
        elseIf response == "Skip this mod"
            SetCurrentlySkippingModName(modName)
        endIf
    endIf
endFunction

function RefreshMcmPage(SKI_ConfigBase mcm, string modName, string pageName) global
    McmRecorder_McmFields.ResetMcmOptions()
    if HasModBeenPlayed(modName)
        mcm.CloseConfig()
    else
        AddModPlayed(modName)
    endIf
    mcm.OpenConfig()
    mcm.SetPage(pageName, mcm.Pages.Find(pageName))
endFunction

function SetIsPlayingRecording(bool running = true) global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_IsPlayingRecording(), running as int, createMissingKeys = true)
endFunction

string function GetCurrentPlayingRecordingModName() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_PlayingRecordingModName())
endFunction

function SetCurrentPlayingRecordingModName(string modName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_PlayingRecordingModName(), modName , createMissingKeys = true)
endFunction

string function GetCurrentPlayingRecordingModPageName() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_PlayingRecordingModPageName())
endFunction

function SetCurrentPlayingRecordingModPageName(string pageName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_PlayingRecordingModPageName(), pageName , createMissingKeys = true)
endFunction

int function GetModsPlayed() global
    int modsPlayed = JDB.solveObj(McmRecorder_JDB.JdbPath_PlayingRecordingModsPlayed())
    if ! modsPlayed
        modsPlayed = JMap.object()
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlayingRecordingModsPlayed(), modsPlayed, createMissingKeys = true)
    endIf
    return modsPlayed
endFunction

function AddModPlayed(string modName) global
    JMap.setInt(GetModsPlayed(), modName, 1)
endFunction

bool function HasModBeenPlayed(string modName) global
    return JMap.getInt(GetModsPlayed(), modName)
endFunction

bool function ClearModsPlayed() global
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlayingRecordingModsPlayed(), 0)
endFunction

string function GetCurrentlySkippingModName() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_CurrentlySkippingModName())
endFunction

int function GetAutorunHistory() global
    int history = JDB.solveObj(McmRecorder_JDB.JdbPath_AutorunHistory())
    if ! history
        history = JMap.object()
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_AutorunHistory(), history, createMissingKeys = true)
    endIf
    return history
endFunction

bool function HasBeenAutorun(string recordingName) global
    return JMap.getInt(GetAutorunHistory(), recordingName)
endFunction

function MarkHasBeenAutorun(string recordingName) global
    JMap.setInt(GetAutorunHistory(), recordingName, 1)
endFunction

function SetCurrentlySkippingModName(string modName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_CurrentlySkippingModName(), modName, createMissingKeys = true)
endFunction

int function FindOption(SKI_ConfigBase mcm, string modName, string pageName, string optionType, string selector, string wildcard, int index, string side, float searchTimeout, float searchInterval, float searchPageLoadTime) global
    int foundOption
    float startTime = Utility.GetCurrentRealTime()
    while (! foundOption) && (Utility.GetCurrentRealTime() - startTime) < searchTimeout
        foundOption = AttemptFindOption(mcm, modName, pageName, optionType, selector, wildcard, index, side, searchInterval, searchPageLoadTime)
        if ! foundOption ; Does this ever run?
            McmRecorder_UI.Notification(modName + ": " + pageName + " (search for " + selector + ")")
            Utility.WaitMenuMode(searchInterval)
        endIf
    endWhile
    return foundOption
endFunction

int function AttemptFindOption(SKI_ConfigBase mcm, string modName, string pageName, string optionType, string selector, string wildcard, int index, string side, float searchInterval, float searchPageLoadTime) global
    float startTime = Utility.GetCurrentRealTime()
    while (Utility.GetCurrentRealTime() - startTime) < searchPageLoadTime
        int options = McmRecorder_McmFields.OptionsForModPage_ByOptionType(modName, pageName, optionType)
        int optionsCount = JArray.count(options)
        int matchCount = 0
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
                matchCount += 1
                if index > -1 ; This must be the Nth one on the page
                    if index == matchCount
                        return option
                    endIf
                else
                    return option
                endIf
            endIf

            i += 1
        endWhile
        
        Utility.WaitMenuMode(searchInterval)

        RefreshMcmPage(mcm, modName, pageName) ; Wasn't on the page! Let's refresh the page.

        string debugPrefix = "[Play Action] " + modName
        if pageName
            debugPrefix += ": " + pageName
        endIf
        debugPrefix += " (" + selector + ")"
        if index > -1
            debugPrefix += " [" + index + "]"
        endIf

        if (Utility.GetCurrentRealTime() - startTime) >= 4 ; Every 4 seconds print an update
            McmRecorder_Logging.ConsoleOut(debugPrefix + " Searching for MCM option...")
            McmRecorder_UI.Notification(modName + ": " + pageName + " (search for " + selector + ")")
        endIf
    endWhile

    return 0
endFunction
