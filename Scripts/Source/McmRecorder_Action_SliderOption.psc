scriptName McmRecorder_Action_SliderOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "slider") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int playback, int actionInfo) global
    if McmRecorder_Playback.IsCanceled(playback) || McmRecorder_Action_Option.ShouldSkipOption(playback)
        return
    endIf

    string modName = McmRecorder_Playback.CurrentModName(playback)
    string pageName = McmRecorder_Playback.CurrentModPageName(playback)
    float sliderValue = JMap.getFlt(actionInfo, "slider")
    string selector = JMap.getStr(actionInfo, "option")
    int index = JMap.getInt(actionInfo, "index", 1)

    McmRecorder_Logging.ConsoleOut("set slider '" + selector + "' to " + sliderValue)

    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if ! mcmMenu
        McmRecorder_UI.McmMenuNotFound(playback, actionInfo, modName)
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(playback, mcmMenu, modName, pageName, "slider", selector, index = index)
    if ! option
        McmRecorder_UI.OptionNotFound(playback, actionInfo, modName, pageName, "slider '" + selector + "'")
        return
    endIf

    PerformAction(mcmMenu, option, sliderValue)
endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, float sliderValue) global
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
