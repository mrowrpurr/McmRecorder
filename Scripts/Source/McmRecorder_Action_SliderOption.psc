scriptName McmRecorder_Action_SliderOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "slider") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int actionInfo) global
    if McmRecorder_Player.IsCurrentRecordingCanceled() || McmRecorder_Action_Option.ShouldSkipOption()
        return
    endIf

    string modName = McmRecorder_Player.GetCurrentPlayingRecordingModName()
    string pageName = McmRecorder_Player.GetCurrentPlayingRecordingModPageName()
    float sliderValue = JMap.getFlt(actionInfo, "slider")
    string selector = JMap.getStr(actionInfo, "option")

    McmRecorder_Logging.ConsoleOut("[Play Action] set slider '" + selector + "' to " + sliderValue)

    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)
    if ! mcmMenu
        McmRecorder_Player.McmMenuNotFound(actionInfo, modName)
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(mcmMenu, modName, pageName, "slider", selector)
    if ! option
        McmRecorder_Player.OptionNotFound(actionInfo, modName, pageName, "slider '" + selector + "'")
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
