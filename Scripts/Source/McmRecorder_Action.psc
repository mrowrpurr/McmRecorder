scriptName McmRecorder_Action hidden

; Delegates all actions to SkyScript

function Play(int playback, int actionList) global
    int scriptInstance = McmRecorder_Playback.GetScript(playback)
    int subscript = SkyScript.Initialize()
    SkyScript.SetScriptParent(subscript, scriptInstance)
    SkyScript.SetScriptActions(subscript, actionList)
    SkyScript.Run(subscript)
endFunction

; TODO account for this!
; TrackMostRecentMcmMenuAndPage(playback, actionInfo) ; Track "mod" and "page"

function TrackMostRecentMcmMenuAndPage(int playback, int actionInfo) global
    if JMap.hasKey(actionInfo, "mod")
        McmRecorder_Playback.SetCurrentModName(playback, JMap.getStr(actionInfo, "mod"))
    endIf
    if JMap.hasKey(actionInfo, "page")
        McmRecorder_Playback.SetCurrentModPageName(playback, JMap.getStr(actionInfo, "page"))
    endIf
    ; If we were skipping a MCM menu and the current mod is no longer that mod, clear the skipping!
    string skippingMod = McmRecorder.GetCurrentlySkippingModName()
    if skippingMod && skippingMod != McmRecorder_Playback.CurrentModName(playback)
        McmRecorder.SetCurrentlySkippingModName("")
    endIf
endFunction
