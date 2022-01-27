scriptName McmRecorder_Action_ColorOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "color") && JMap.hasKey(actionInfo, "option")
endFunction

; !!!!!!!!! TODO ! Support HTML hexadecimal !!!!!!!!!! And save using hex as well !!!!!!!

function Play(int actionInfo) global
    if McmRecorder_Player.IsCurrentRecordingCanceled() || McmRecorder_Action_Option.ShouldSkipOption()
        return
    endIf

    string modName = McmRecorder_Player.GetCurrentPlayingRecordingModName()
    string pageName = McmRecorder_Player.GetCurrentPlayingRecordingModPageName()
    int color = JMap.getInt(actionInfo, "color") ; Right now this is an Int but will support Strings
    string selector = JMap.getStr(actionInfo, "option")
    int index = JMap.getInt(actionInfo, "index", 1)

    McmRecorder_Logging.ConsoleOut("[Play Action] set color '" + selector + "' to " + color) ; TODO make this HEX

    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if ! mcmMenu
        McmRecorder_Player.McmMenuNotFound(actionInfo, modName)
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(mcmMenu, modName, pageName, "color", selector, index = index)
    if ! option
        McmRecorder_Player.OptionNotFound(actionInfo, modName, pageName, "color '" + selector + "'")
        return
    endIf

    PerformAction(mcmMenu, option, color)
endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, int color) global
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
