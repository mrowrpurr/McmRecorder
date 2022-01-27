scriptName McmRecorder_Action_Option hidden

; Find an option. Assumed running in the context of a running recording.
int function GetOption(SKI_ConfigBase mcmMenu, string modName, string pageName, string optionType, string selector, string side = "left", int index = -1) global
    ; If this isn't the same MCM that was previously played, refresh it!
    if modName != McmRecorder_Player.GetCurrentPlayingRecordingModName() || pageName != McmRecorder_Player.GetCurrentPlayingRecordingModPageName()
        bool forceRefresh = false
        if McmRecorder_Player.HasModBeenPlayed(modName)
            forceRefresh = true
        else
            McmRecorder_Player.AddModPlayed(modName)
        endIf
        McmRecorder_ModConfigurationMenu.Refresh(mcmMenu, modName, pageName, forceRefresh)
    endIf

    string wildcard = McmRecorder_McmFields.GetWildcardMatcher(selector)

    int option = McmRecorder_ModConfigurationMenu.FindOption(mcmMenu, modName, pageName, optionType, selector, wildcard, index, side)

    return option
endFunction

bool function ShouldSkipOption() global
    string skippingMod = McmRecorder_Player.GetCurrentlySkippingModName()
    return skippingMod && skippingMod == McmRecorder_Player.GetCurrentPlayingRecordingModName()
endFunction

