scriptName McmRecorder_Action_TextOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "click")
endFunction

function Play(int actionInfo) global
    if McmRecorder_Player.IsCurrentRecordingCanceled() || McmRecorder_Action_Option.ShouldSkipOption()
        return
    endIf

    string modName = McmRecorder_Player.GetCurrentPlayingRecordingModName()
    string pageName = McmRecorder_Player.GetCurrentPlayingRecordingModPageName()
    string selector = JMap.getStr(actionInfo, "click")
    string side = JMap.getStr(actionInfo, "side", "left")
    int index = JMap.getInt(actionInfo, "index", 1)

    McmRecorder_Logging.ConsoleOut("[Play Action] click on '" + selector + "'")
    
    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if ! mcmMenu
        McmRecorder_Player.McmMenuNotFound(actionInfo, modName)
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(mcmMenu, modName, pageName, "text", selector, side, index)
    if ! option
        McmRecorder_Player.OptionNotFound(actionInfo, modName, pageName, "text '" + selector + "'")
        return
    endIf

    PerformAction(mcmMenu, option)
endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option) global
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
