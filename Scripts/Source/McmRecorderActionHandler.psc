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
endEvent

int function Execute(int scriptInstance, int actionInfo)
    int playback = GetPlayback(scriptInstance)
    if McmRecorder_Playback.IsCanceled(playback) || McmRecorder_Action_Option.ShouldSkipOption(playback)
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

    bool showErrorMessages = SkyScript.GetVariableBool(scriptInstance, "topLevelRecording", false)

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
    elseIf JMap.hasKey(actionInfo, "mod") || JMap.hasKey(actionInfo, "page")
        ChangePage(mcmMenu, modName, pageName, index, playback, scriptInstance, actionInfo, showErrorMessages)
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
endFunction

int function Toggle(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
    string toggleOption = JMap.getStr(actionInfo, "option")
    string toggleAction = JMap.getStr(actionInfo, "toggle")

    int option = McmRecorder_Action_Option.GetOption(playback, mcmMenu, modName, pageName, "toggle", selector = toggleOption, index = index)

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
endFunction

int function Color(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
endFunction

int function Shortcut(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
endFunction

int function Menu(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
endFunction

int function Slider(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
endFunction

int function ChangePage(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
endFunction

int function PlayRecording(SKI_ConfigBase mcmMenu, string modName, string pageName, int index, int playback, int scriptInstance, int actionInfo, bool showErrorMessages)
endFunction
