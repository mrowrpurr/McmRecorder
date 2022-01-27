scriptName McmRecorder_Action_ToggleOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "toggle") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int actionInfo) global
    if McmRecorder_Player.IsCurrentRecordingCanceled() || McmRecorder_Action_Option.ShouldSkipOption()
        return
    endIf

    string modName = McmRecorder_Player.GetCurrentPlayingRecordingModName()
    string pageName = McmRecorder_Player.GetCurrentPlayingRecordingModPageName()
    string toggleAction = JMap.getStr(actionInfo, "toggle")
    string toggleOption = JMap.getStr(actionInfo, "option")
    int index = JMap.getInt(actionInfo, "index", 1)

    McmRecorder_Logging.ConsoleOut("[Play Action] toggle '" + toggleOption + "' to " + toggleAction)
    
    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if ! mcmMenu
        McmRecorder_Player.McmMenuNotFound(actionInfo, modName)
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(mcmMenu, modName, pageName, "toggle", selector = toggleOption, index = index)
    if ! option
        McmRecorder_Player.OptionNotFound(actionInfo, modName, pageName, "toggle '" + toggleOption + "'")
        return
    endIf

    PerformAction(mcmMenu, option, toggleAction)
endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, string toggleAction) global
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

