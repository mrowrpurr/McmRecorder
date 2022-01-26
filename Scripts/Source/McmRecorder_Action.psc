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
    else
        if ! JMap.hasKey(actionInfo, "mod") && ! JMap.hasKey(actionInfo, "page")
            Debug.MessageBox("Unknown Action: " + McmRecorder_Logging.ToJson(actionInfo)) ; Move this to a log!
        endIf
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

;;;;;;;;;;;;

; function PlayAction_ORIGINAL(int actionInfo, string stepName, bool promptOnFailures = true, float mcmLoadWaitTime = 10.0) global    




;     string optionType
;     string selector = JMap.getStr(actionInfo, "option")
;     string selectorType = "text"

;     int actionMetaInfo = JMap.object()
;     JValue.retain(actionMetaInfo)
;     JMap.setStr(actionMetaInfo, "mcmModName", modName)
;     JMap.setStr(actionMetaInfo, "mcmPageName", pageName)
;     JMap.setStr(actionMetaInfo, "recordingStepName", stepName)

;     if JMap.hasKey(actionInfo, "click")
;         optionType = "text"
;         selector = JMap.getStr(actionInfo, "click")
;     elseIf JMap.hasKey(actionInfo, "toggle")
;         optionType = "toggle"
;     elseIf JMap.hasKey(actionInfo, "choose")
;         optionType = "menu"
;     elseIf JMap.hasKey(actionInfo, "chooseIndex")
;         optionType = "menu"
;         selectorType = "index"
;     elseIf JMap.hasKey(actionInfo, "text")
;         optionType = "input"
;     elseIf JMap.hasKey(actionInfo, "shortcut")
;         optionType = "keymap"
;     elseIf JMap.hasKey(actionInfo, "color")
;         optionType = "color"
;     elseIf JMap.hasKey(actionInfo, "slider") ; <--- TODO next: start moving these over into their own files :)
;         optionType = "slider"
;     else
;         ; Prototyping new action calling
;         McmRecorder_Action.Play(actionInfo, actionMetaInfo)
;         return
;     endIf

; endFunction