scriptName McmRecorder_Action hidden

function PlayList(int actionList) global
    int actionCount = JArray.count(actionList)
    if actionCount
        int i = 0
        while i < actionCount
            int actionInfo = JArray.getObj(actionList, i)
            Play(actionInfo)
            i += 1
        endWhile
    endIf
endFunction

function Play(int actionInfo) global
    TrackMostRecentMcmMenuAndPage(actionInfo) ; Track "mod" and "page"

    if McmRecorder_Action_MessageBox.IsActionType(actionInfo)
        McmRecorder_Action_MessageBox.Play(actionInfo)
    elseIf McmRecorder_Action_ToggleOption.IsActionType(actionInfo)
        McmRecorder_Action_ToggleOption.Play(actionInfo)
    elseIf McmRecorder_Action_InputOption.IsActionType(actionInfo)
        McmRecorder_Action_InputOption.Play(actionInfo)
    elseIf McmRecorder_Action_TextOption.IsActionType(actionInfo)
        McmRecorder_Action_TextOption.Play(actionInfo)
    elseIf McmRecorder_Action_ColorOption.IsActionType(actionInfo)
        McmRecorder_Action_ColorOption.Play(actionInfo)
    elseIf McmRecorder_Action_KeymapOption.IsActionType(actionInfo)
        McmRecorder_Action_KeymapOption.Play(actionInfo)
    elseIf McmRecorder_Action_MenuOption.IsActionType(actionInfo)
        McmRecorder_Action_MenuOption.Play(actionInfo)
    elseIf McmRecorder_Action_SliderOption.IsActionType(actionInfo)
        McmRecorder_Action_SliderOption.Play(actionInfo)
    else
        ; Nothing right now...
    endIf
endFunction

function TrackMostRecentMcmMenuAndPage(int actionInfo) global
    if JMap.hasKey(actionInfo, "mod")
        McmRecorder_Player.SetCurrentPlayingRecordingModName(JMap.getStr(actionInfo, "mod"))
    endIf
    if JMap.hasKey(actionInfo, "page")
        McmRecorder_Player.SetCurrentPlayingRecordingModPageName(JMap.getStr(actionInfo, "page"))
    endIf
    ; If we were skipping a MCM menu and the current mod is no longer that mod, clear the skipping!
    string skippingMod = McmRecorder_Player.GetCurrentlySkippingModName()
    if skippingMod && skippingMod != McmRecorder_Player.GetCurrentPlayingRecordingModName()
        McmRecorder_Player.SetCurrentlySkippingModName("")
    endIf
endFunction
