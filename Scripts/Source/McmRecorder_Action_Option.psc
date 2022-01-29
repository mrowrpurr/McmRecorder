scriptName McmRecorder_Action_Option hidden

; Find an option. Assumed running in the context of a running recording.
int function GetOption(int playback, SKI_ConfigBase mcmMenu, string modName, string pageName, string optionType, string selector, string side = "left", int index = -1) global
    ; If this isn't the same MCM that was previously played, refresh it!
    if modName != McmRecorder_Playback.CurrentModName(playback) || pageName != McmRecorder_Playback.CurrentModPageName(playback)
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

bool function ShouldSkipOption(int playback) global
    string skippingMod = McmRecorder_Player.GetCurrentlySkippingModName()
    return skippingMod && skippingMod == McmRecorder_Playback.CurrentModName(playback)
endFunction

