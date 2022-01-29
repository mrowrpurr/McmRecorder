scriptName McmRecorder_Action_InputOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "text") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int playback, int actionInfo) global
    if McmRecorder_Playback.IsCanceled(playback) || McmRecorder_Action_Option.ShouldSkipOption(playback)
        return
    endIf

    string modName = McmRecorder_Playback.CurrentModName(playback)
    string pageName = McmRecorder_Playback.CurrentModPageName(playback)
    string text = JMap.getStr(actionInfo, "text")
    string selector = JMap.getStr(actionInfo, "option")
    int index = JMap.getInt(actionInfo, "index", 1)

    McmRecorder_Logging.ConsoleOut("[Play Action] set '" + selector + "' to '" + text + "'")
    
    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if ! mcmMenu
        McmRecorder_Player.McmMenuNotFound(playback, actionInfo, modName)
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(playback, mcmMenu, modName, pageName, "input", selector, index = index)
    if ! option
        McmRecorder_Player.OptionNotFound(playback, actionInfo, modName, pageName, "text input '" + selector + "'")
        return
    endIf

    PerformAction(mcmMenu, option, text)
endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, string text) global
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
