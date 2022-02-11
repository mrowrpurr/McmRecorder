scriptName McmRecorderActionHandler extends SkyScriptActionHandler

; TrackMostRecentMcmMenuAndPage(playback, actionInfo) ; Track "mod" and "page"

event RegisterSyntax()
    AddSyntax("click")
    AddSyntax("toggle")
    AddSyntax("input")
    AddSyntax("color")
    AddSyntax("shortcut")
    AddSyntax("menu")
    AddSyntax("slider")
    AddSyntax("mod")
    AddSyntax("page")
    AddSyntax("play")
endEvent

int function Execute(int scriptInstance, int actionInfo)
    bool showErrorMessages = SkyScript.GetVariableBool(scriptInstance, "topLevelRecording", false)
    
    if JMap.hasKey(actionInfo, "play")
        PlayRecording(scriptInstance, actionInfo, showErrorMessages)
        return 0
    endIf

    int playback = GetPlayback(scriptInstance)

    if ! playback
        playback = McmRecorder_Playback.Create()
    endIf

    if McmRecorder_Playback.IsCanceled(playback) || ShouldSkipOption(playback)
        return 0
    endIf

    int index = JMap.getInt(actionInfo, "index", 1)
    string modName = SkyScript.GetVariableString(scriptInstance, "modName")
    string pageName = SkyScript.GetVariableString(scriptInstance, "pageName")

    if JMap.hasKey(actionInfo, "mod")
        modName = JMap.getStr(actionInfo, "mod")
        SkyScript.SetVariableString(scriptInstance, "modName", modName)
    endIf

    if JMap.hasKey(actionInfo, "page")
        pageName = JMap.getStr(actionInfo, "page")
        SkyScript.SetVariableString(scriptInstance, "pageName", pageName)
    endIf

    ; For now, let's just do this...
    McmRecorder_Playback.SetCurrentModName(playback, modName)
    McmRecorder_Playback.SetCurrentModPageName(playback, pageName)

    SKI_ConfigBase mcmMenu = GetMcmMenu(playback, actionInfo, modName, showNotFoundMessage = showErrorMessages)

    if ! mcmMenu
        return 0
    endIf

    if JMap.hasKey(actionInfo, "click")
        Click(mcmMenu, modName, pageName, index, playback, scriptInstance, actionInfo, showErrorMessages)
    elseIf JMap.hasKey(actionInfo, "toggle")
        Toggle(mcmMenu, modName, pageName, index, playback, scriptInstance, actionInfo, showErrorMessages)
    elseIf JMap.hasKey(actionInfo, "input")
        Input(mcmMenu, modName, pageName, index, playback, scriptInstance, actionInfo, showErrorMessages)
    elseIf JMap.hasKey(actionInfo, "color")
        Color(mcmMenu, modName, pageName, index, playback, scriptInstance, actionInfo, showErrorMessages)
    elseIf JMap.hasKey(actionInfo, "shortcut")
        Shortcut(mcmMenu, modName, pageName, index, playback, scriptInstance, actionInfo, showErrorMessages)
    elseIf JMap.hasKey(actionInfo, "menu")
        Menu(mcmMenu, modName, pageName, index, playback, scriptInstance, actionInfo, showErrorMessages)
    elseIf JMap.hasKey(actionInfo, "slider")
        Slider(mcmMenu, modName, pageName, index, playback, scriptInstance, actionInfo, showErrorMessages)
    endIf

    return 0
endFunction

int function GetPlayback(int scriptInstance)
    return SkyScript.GetVariableObject(scriptInstance, "playback")
endFunction

SKI_ConfigBase function GetMcmMenu(int playback, int actionInfo, string modName, bool showNotFoundMessage = false)
    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if mcmMenu
        return mcmMenu
    elseIf showNotFoundMessage
        McmRecorder_UI.McmMenuNotFound(playback, actionInfo, modName)
        return None
    endIf
endFunction

int function Click(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
    string selector = JMap.getStr(actionInfo, "click")
    string side = JMap.getStr(actionInfo, "side", "left")

    McmRecorder_Logging.ConsoleOut("click on '" + selector + "'")

    int option = GetOption(playback, mcmMenu, modName, pageName, "text", selector, side, index)

    if (! option) && showErrorMessages
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "text '" + selector + "'")
        return 0
    endIf

    int optionId = JMap.getInt(option, "id")
    string stateName = JMap.getStr(option, "state")
    if stateName
        string previousState = mcmMenu.GetState()
        mcmMenu.GotoState(stateName)
        mcmMenu.OnSelectST()
        mcmMenu.GotoState(previousState)
    else
        mcmMenu.OnOptionSelect(optionId)
    endIf
endFunction

int function Toggle(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
    string toggleOption = JMap.getStr(actionInfo, "option")
    string toggleAction = JMap.getStr(actionInfo, "toggle")

    McmRecorder_Logging.ConsoleOut("toggle '" + toggleOption + "' to " + toggleAction)

    int option = GetOption(playback, mcmMenu, modName, pageName, "toggle", selector = toggleOption, index = index)

    if (! option) && showErrorMessages
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "toggle '" + toggleOption + "'")
        return 0
    endIf

    int optionId = JMap.getInt(option, "id")
    string stateName = JMap.getStr(option, "state")
    bool currentlyEnabledOnPage = JMap.getFlt(option, "fltValue") == 1

    if stateName
        string previousState = mcmMenu.GetState()
        mcmMenu.GotoState(stateName)
        if currentlyEnabledOnPage && toggleAction == "off"
            mcmMenu.OnSelectST() ; Turn off
        elseIf (!currentlyEnabledOnPage) && toggleAction == "on"
            mcmMenu.OnSelectST() ; Turn on
        elseIf toggleAction == "toggle"
            mcmMenu.OnSelectST() ; Flip!
        endIf
        mcmMenu.GotoState(previousState)
    else
        if currentlyEnabledOnPage && toggleAction == "off"
            mcmMenu.OnOptionSelect(optionId) ; Turn off
        elseIf (!currentlyEnabledOnPage) && toggleAction == "on"
            mcmMenu.OnOptionSelect(optionId) ; Turn on
        elseIf toggleAction == "toggle"
            mcmMenu.OnOptionSelect(optionId) ; Flip!
        endIf
    endIf
endFunction

int function Input(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
    string text = JMap.getStr(actionInfo, "text")
    string selector = JMap.getStr(actionInfo, "option")

    McmRecorder_Logging.ConsoleOut("set '" + selector + "' to '" + text + "'")

    int option = GetOption(playback, mcmMenu, modName, pageName, "input", selector, index = index)

    if (! option) && showErrorMessages
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "text input '" + selector + "'")
        return 0
    endIf

    int optionId = JMap.getInt(option, "id")
    string stateName = JMap.getStr(option, "state")
    if stateName
        string previousState = mcmMenu.GetState()
        mcmMenu.GotoState(stateName)
        mcmMenu.OnInputAcceptST(text)
        mcmMenu.GotoState(previousState)
    else
        mcmMenu.OnOptionInputAccept(optionId, text)
    endIf
endFunction

; TODO COLOR CODES !!!!!!
int function Color(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
    int color = JMap.getInt(actionInfo, "color") ; Right now this is an Int but will support Strings
    string selector = JMap.getStr(actionInfo, "option")

    McmRecorder_Logging.ConsoleOut("set color '" + selector + "' to " + color) ; TODO make this HEX

    int option = GetOption(playback, mcmMenu, modName, pageName, "color", selector, index = index)

    if (! option) && showErrorMessages
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "color '" + selector + "'")
        return 0
    endIf

    int optionId = JMap.getInt(option, "id")
    string stateName = JMap.getStr(option, "state")
    if stateName
        string previousState = mcmMenu.GetState()
        mcmMenu.GotoState(stateName)
        mcmMenu.OnColorAcceptST(color)
        mcmMenu.GotoState(previousState)
    else
        mcmMenu.OnOptionColorAccept(optionId, color)
    endIf
endFunction

int function Shortcut(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
    int shortcut = JMap.getInt(actionInfo, "shortcut")
    string selector = JMap.getStr(actionInfo, "option")

    McmRecorder_Logging.ConsoleOut("set keyboard shortcut '" + selector + "' to " + shortcut + " keycode") ; TODO make this HEX

    int option = GetOption(playback, mcmMenu, modName, pageName, "keymap", selector, index = index)

    if (! option) && showErrorMessages
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "keyboard shortcut '" + selector + "'")
        return 0
    endIf

    int optionId = JMap.getInt(option, "id")
    string stateName = JMap.getStr(option, "state")
    if stateName
        string previousState = mcmMenu.GetState()
        mcmMenu.GotoState(stateName)
        mcmMenu.OnKeyMapChangeST(shortcut, "", "")
        mcmMenu.GotoState(previousState)
    else
        mcmMenu.OnOptionKeyMapChange(optionId, shortcut, "", "")
    endIf
endFunction

int function Menu(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
    string menuOptionName = JMap.getStr(actionInfo, "choose")
    int menuOptionIndex = JMap.getInt(actionInfo, "chooseIndex")
    string selector = JMap.getStr(actionInfo, "option")

    if JMap.hasKey(actionInfo, "choose")
        McmRecorder_Logging.ConsoleOut("choose '" + menuOptionName + "' from '" + selector + "'")
    elseIf JMap.hasKey(actionInfo, "chooseIndex")
        McmRecorder_Logging.ConsoleOut("choose option number " + (menuOptionIndex + 1) + " from '" + selector + "'")
    endIf

    int option = GetOption(playback, mcmMenu, modName, pageName, "menu", selector, index = index)

    if (! option) && showErrorMessages
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "menu '" + selector + "'")
        return 0
    endIf

    if JMap.hasKey(actionInfo, "choose")
        int optionId = JMap.getInt(option, "id")
        string stateName = JMap.getStr(option, "state")
        if stateName
            string previousState = mcmMenu.GetState()
            mcmMenu.GotoState(stateName)
            mcmMenu.OnMenuOpenST()
            mcmMenu.GotoState(previousState)
            string[] menuOptions = McmRecorder_McmFields.GetLatestMenuOptions(mcmMenu) ; TODO - find a way to make this work with MCM Helper
            int itemIndex = menuOptions.Find(menuOptionName)
            if itemIndex == -1
                McmRecorder_UI.MessageBox("Could not find " + menuOptionName + " menu item. Available options: " + menuOptions)
            else
                mcmMenu.OnMenuAcceptST(itemIndex)
            endIf
        else
            mcmMenu.OnOptionMenuOpen(optionId)
            string[] menuOptions = McmRecorder_McmFields.GetLatestMenuOptions(mcmMenu)
            int itemIndex = menuOptions.Find(menuOptionName)
            if itemIndex == -1
                McmRecorder_UI.MessageBox("Could not find " + menuOptionName + " menu item. Available options: " + menuOptions)
            else
                mcmMenu.OnOptionMenuAccept(optionId, itemIndex)
            endIf
        endIf

    elseIf JMap.hasKey(actionInfo, "chooseIndex")
        int optionId = JMap.getInt(option, "id")
        string stateName = JMap.getStr(option, "state")
        if stateName
            string previousState = mcmMenu.GetState()
            mcmMenu.GotoState(stateName)
            mcmMenu.OnMenuAcceptST(menuOptionIndex)
            mcmMenu.GotoState(previousState)
        else
            mcmMenu.OnOptionMenuAccept(optionId, menuOptionIndex)
        endIf
    endIf
endFunction

int function Slider(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
    float sliderValue = JMap.getFlt(actionInfo, "slider")
    string selector = JMap.getStr(actionInfo, "option")

    McmRecorder_Logging.ConsoleOut("set slider '" + selector + "' to " + sliderValue)

    int option = GetOption(playback, mcmMenu, modName, pageName, "slider", selector, index = index)

    if (! option) && showErrorMessages
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "slider '" + selector + "'")
        return 0
    endIf

    int optionId = JMap.getInt(option, "id")
    string stateName = JMap.getStr(option, "state")
    if stateName
        string previousState = mcmMenu.GetState()
        mcmMenu.GotoState(stateName)
        mcmMenu.OnSliderAcceptST(sliderValue)
        mcmMenu.GotoState(previousState)
    else
        mcmMenu.OnOptionSliderAccept(optionId, sliderValue)
    endIf
endFunction

int function PlayRecording(int scriptInstance, int actionInfo, bool showErrorMessages)
    string recording = JMap.getStr(actionInfo, "play")
    string stepName = JMap.getStr(actionInfo, "step")
    int recordingId = McmRecorder_Recording.Get(recording) ; Only works if the recording is actually a recording name, not a file name!

    string recordingName

    ; Was this a file that was directly specified?
    string recordingFile
    if StringUtil.Find(recording, ".json") > -1
        ; Was the full path to a file specified?
        if JContainers.fileExistsAtPath(recording)
            recordingFile = recording
        else
            string potentialRecordingPath = McmRecorder_Files.GetMcmRecordingsDataPath() + "/" + recording
            if JContainers.fileExistsAtPath(potentialRecordingPath)
                recordingFile = potentialRecordingPath
                if StringUtil.Find(recording, "/") == -1 && StringUtil.Find(recording, "\\") == -1
                    ; It's a top-level recording. Get its name and use that to play it.
                    recordingFile = "" ; <--- we're not going to play it like a directly played step file
                    int recordingFileInfo = McmRecorder_Files.ReadRecordingFile(recording)
                    if recordingFileInfo
                        recordingName = McmRecorder_Recording.GetName(recordingFileInfo)
                    endIf
                endIf
            endIf
        endIf
    endIf

    if stepName
        if recordingId
            string recordingFolder = McmRecorder_Files.PathToRecordingFolder(recording)
            string pathToStep
            if StringUtil.Find(stepName, ".json") > -1
                pathToStep = recordingFolder + "/" + stepName
            else
                pathToStep = recordingFolder + "/" + stepName + ".json"
            endIf
            if JContainers.fileExistsAtPath(pathToStep)
                recordingFile = pathToStep
            elseIf showErrorMessages
                McmRecorder_UI.MessageBox("Could not find specified step: " + pathToStep)
            endIf
        elseIf showErrorMessages
            McmRecorder_UI.MessageBox("Could not find specified recording: " + recording + " to play step: " + stepName)
        endIf
    endIf

    if (! recordingFile) && (! recordingName)
        if recordingId
            recordingName = recording
        endIf
    endIf

    if recordingFile ; This could be any file, including a step of an existing recording
        int subscriptActions = JValue.readFromFile(recordingFile)
        if subscriptActions
            int subscript = SkyScript.Initialize()
            SkyScript.SetScriptParent(subscript, scriptInstance)
            SkyScript.SetScriptActions(subscript, subscriptActions)
            SkyScript.Run(subscript)
        elseIf showErrorMessages
            McmRecorder_UI.MessageBox("Could not play specified recording: " + recordingFile)
        endIf

    elseIf recordingName
        recordingId = McmRecorder_Recording.Get(recordingName)
        int playback = McmRecorder_Playback.Create(recordingId, parentScript = scriptInstance)
        McmRecorder_Playback.Play(playback)

    elseIf showErrorMessages
        McmRecorder_UI.MessageBox("Could not find specified recording to play: " + SkyScript.ToJson(actionInfo))
    endIf
endFunction

; Find an option. Assumed running in the context of a running recording.
int function GetOption(int playback, SKI_ConfigBase mcmMenu, string modName, string pageName, string optionType, string selector, string side = "left", int index = -1) global
    ; If this isn't the same MCM that was previously played, refresh it!
    if modName != McmRecorder_Playback.CurrentModName(playback) || pageName != McmRecorder_Playback.CurrentModPageName(playback)
        bool forceRefresh = false
        if McmRecorder.HasModBeenPlayed(modName)
            forceRefresh = true
        else
            McmRecorder.AddModPlayed(modName)
        endIf
        McmRecorder_ModConfigurationMenu.Refresh(mcmMenu, modName, pageName, forceRefresh)
    endIf

    string wildcard = McmRecorder_McmFields.GetWildcardMatcher(selector)

    int option = McmRecorder_ModConfigurationMenu.FindOption(mcmMenu, modName, pageName, optionType, selector, wildcard, index, side)

    return option
endFunction

bool function ShouldSkipOption(int playback) global
    string skippingMod = McmRecorder.GetCurrentlySkippingModName()
    return skippingMod && skippingMod == McmRecorder_Playback.CurrentModName(playback)
endFunction
