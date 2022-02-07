scriptName McmRecorder_Action_KeymapOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "shortcut") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int playback, int actionInfo) global
    if McmRecorder_Playback.IsCanceled(playback) || McmRecorder_Action_Option.ShouldSkipOption(playback)
        return
    endIf

    string modName = McmRecorder_Playback.CurrentModName(playback)
    string pageName = McmRecorder_Playback.CurrentModPageName(playback)
    int shortcut = JMap.getInt(actionInfo, "shortcut")
    string selector = JMap.getStr(actionInfo, "option")
    int index = JMap.getInt(actionInfo, "index", 1)

    McmRecorder_Logging.ConsoleOut("set keyboard shortcut '" + selector + "' to " + shortcut + " keycode") ; TODO make this HEX

    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if ! mcmMenu
        McmRecorder_UI.McmMenuNotFound(playback, actionInfo, modName)
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(playback, mcmMenu, modName, pageName, "keymap", selector, index = index)
    if ! option
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "keyboard shortcut '" + selector + "'")
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
