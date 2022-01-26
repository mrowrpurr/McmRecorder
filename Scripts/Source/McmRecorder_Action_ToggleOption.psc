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

    McmRecorder_Logging.ConsoleOut("[Play Action] toggle '" + toggleOption + "' to " + toggleAction)
    
    SKI_ConfigBase mcmMenu = McmRecorder_ModConfigurationMenu.GetMenu(modName)

    if ! mcmMenu
        ; TODO!
        Debug.MessageBox("Oh jeepers, couldn't find MCM menu!") ; <-- do thing that asks to skip mod etc
        return
    endIf

    int option = McmRecorder_Action_Option.GetOption(mcmMenu, "toggle", selector = toggleOption)

    if ! option
        ; Oh jeepers, do something!
        Debug.MessageBox("Oh jeepers, couldn't find toggle option!") ; <-- do thing that asks to skip mod etc
        return
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


    ; TODO get the skipping working again when the MCM menu is not found! <---

    ; if ! mcmMenu
    ;     if interactive
    ;         string result = McmRecorder_UI.GetUserResponseForNotFoundMod(modName)
    ;         if result == "Try again"
    ;             McmRecorder_Action.Play(actionInfo)
    ;         elseIf result == "Skip this mod"
    ;             SetCurrentlySkippingModName(modName)
    ;             return 0
    ;         endIf
    ;     else
    ;         SetCurrentlySkippingModName(modName)
    ;         return 0
    ;     endIf
    ;     return 0
    ; endIf