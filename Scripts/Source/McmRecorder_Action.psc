scriptName McmRecorder_Action hidden

function PlayMultiple(int playback, int actionList) global
    int actionCount = JArray.count(actionList)
    if actionCount
        int i = 0
        while i < actionCount
            int actionInfo = JArray.getObj(actionList, i)
                Play(playback, actionInfo)
            i += 1
        endWhile
    endIf
endFunction

function Play(int playback, int actionInfo) global
    TrackMostRecentMcmMenuAndPage(playback, actionInfo) ; Track "mod" and "page"

    if McmRecorder_Action_MessageBox.IsActionType(actionInfo)
        McmRecorder_Action_MessageBox.Play(playback, actionInfo)
    elseIf McmRecorder_Action_ToggleOption.IsActionType(actionInfo)
        McmRecorder_Action_ToggleOption.Play(playback, actionInfo)
    elseIf McmRecorder_Action_InputOption.IsActionType(actionInfo)
        McmRecorder_Action_InputOption.Play(playback, actionInfo)
    elseIf McmRecorder_Action_TextOption.IsActionType(actionInfo)
        McmRecorder_Action_TextOption.Play(playback, actionInfo)
    elseIf McmRecorder_Action_ColorOption.IsActionType(actionInfo)
        McmRecorder_Action_ColorOption.Play(playback, actionInfo)
    elseIf McmRecorder_Action_KeymapOption.IsActionType(actionInfo)
        McmRecorder_Action_KeymapOption.Play(playback, actionInfo)
    elseIf McmRecorder_Action_MenuOption.IsActionType(actionInfo)
        McmRecorder_Action_MenuOption.Play(playback, actionInfo)
    elseIf McmRecorder_Action_SliderOption.IsActionType(actionInfo)
        McmRecorder_Action_SliderOption.Play(playback, actionInfo)
    elseIf McmRecorder_Action_Chooser.IsActionType(actionInfo)
        McmRecorder_Action_Chooser.Play(playback, actionInfo)
    elseIf McmRecorder_Action_Play.IsActionType(actionInfo)
        McmRecorder_Action_Play.Play(playback, actionInfo)
    else
        ; Nothing right now...
    endIf
endFunction

function TrackMostRecentMcmMenuAndPage(int playback, int actionInfo) global
    if JMap.hasKey(actionInfo, "mod")
        McmRecorder_Playback.SetCurrentModName(playback, JMap.getStr(actionInfo, "mod"))
    endIf
    if JMap.hasKey(actionInfo, "page")
        McmRecorder_Playback.SetCurrentModPageName(playback, JMap.getStr(actionInfo, "page"))
    endIf
    ; If we were skipping a MCM menu and the current mod is no longer that mod, clear the skipping!
    string skippingMod = McmRecorder_Player.GetCurrentlySkippingModName()
    if skippingMod && skippingMod != McmRecorder_Playback.CurrentModName(playback)
        McmRecorder_Player.SetCurrentlySkippingModName("")
    endIf
endFunction
