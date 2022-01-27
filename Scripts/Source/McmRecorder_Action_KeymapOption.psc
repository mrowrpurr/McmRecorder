scriptName McmRecorder_Action_KeymapOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "shortcut") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int actionInfo) global
    if McmRecorder_Player.IsCurrentRecordingCanceled() || McmRecorder_Action_Option.ShouldSkipOption()
        return
    endIf

    string modName = McmRecorder_Player.GetCurrentPlayingRecordingModName()
    string pageName = McmRecorder_Player.GetCurrentPlayingRecordingModPageName()
    int shortcut = JMap.getInt(actionInfo, "shortcut")
    string selector = JMap.getStr(actionInfo, "option")

    McmRecorder_Logging.ConsoleOut("[Play Action] set keyboard shortcut '" + selector + "' to " + shortcut + " keycode") ; TODO make this HEX

    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if ! mcmMenu
        McmRecorder_Player.McmMenuNotFound(actionInfo, modName)
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(mcmMenu, modName, pageName, "keymap", selector)
    if ! option
        McmRecorder_Player.OptionNotFound(actionInfo, modName, pageName, "keyboard shortcut '" + selector + "'")
        return
    endIf

    PerformAction(mcmMenu, option, shortcut)
endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, int shortcut) global
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
