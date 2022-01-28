scriptName McmRecorder_JDB hidden
{Get JDB paths for JDB data stored by MCM Recorder}

string function JdbPathPart(string part) global
    string[] parts = StringUtil.Split(part, ".")
    string sanitized = ""
    int i = 0
    while i < parts.Length
        if i == 0
            sanitized += parts[i]
        else
            sanitized += "_" + parts[i]
        endIf
        i += 1
    endWhile
    return sanitized
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Current Recording
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function JdbPath_CurrentRecordingName() global
    return ".mcmRecorder.currentRecording.recordingName"
endFunction

string function JdbPath_CurrentRecordingModName() global
    return ".mcmRecorder.currentRecording.currentModName"
endFunction

string function JdbPath_CurrentRecordingModPageName() global
    return ".mcmRecorder.currentRecording.currentPageName"
endFunction

string function JdbPath_CurrentRecordingRecordingStep() global
    return ".mcmRecorder.currentRecording.currentModStep"
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MCM Fields
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function JdbPath_McmOptions() global
    return ".mcmRecorder.mcmOptions"
endFunction

string function JdbPath_McmOptions_MarkForReset() global
    return ".mcmRecorder.McmOptionsShouldBeReset"
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Recording Playback
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function JdbPath_TopLevelPlaybackId() global
    return ".mcmRecorder.topLevelPlayback"
endFunction

string function JdbPath_Playbacks() global
    return ".mcmRecorder.playbacks"
endFunction

string function JdbPath_PlaybackById(int playback) global
    return ".mcmRecorder.playbacks." + playback
endFunction

string function JdbPath_Playback_Recording(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".recording"
endFunction

string function JdbPath_Playback_IsPlaying(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".isPlaying"
endFunction

string function JdbPath_Playback_IsPaused(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".isPaused"
endFunction

string function JdbPath_Playback_IsCanceled(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".isCanceled"
endFunction

string function JdbPath_Playback_StepsByFilename(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".stepsByFilename"
endFunction

string function JdbPath_Playback_InlineScript(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".inlineScript"
endFunction

string function JdbPath_Playback_CurrentModName(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".currentModName"
endFunction

string function JdbPath_Playback_CurrentModPageName(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".currentModPageName"
endFunction

string function JdbPath_Playback_CurrentStepFilename(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".currentStepFilename"
endFunction

string function JdbPath_Playback_CurrentActionIndex(int playback) global
    return ".mcmRecorder.playbacks." + playback + ".currentActionIndex"
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Autorun
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function JdbPath_AutorunHistory() global
    return ".mcmRecorder.autorunHistory"
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Keyboard Shortcuts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function JdbPath_MCM_KeyboardShortcuts_ShortcutInfos() global
    return ".mcmRecorder.mcm.keyboardShortcuts.shortcutInfos"
endFunction

string function JdbPath_MCM_KeyboardShortcuts_ShortcutOptions() global
    return ".mcmRecorder.mcm.keyboardShortcuts.shortcutOptions"
endFunction
















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Playing Recording (ORIGINAL - DEPRECATE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function JdbPath_IsPlayingRecording() global
    return ".mcmRecorder.isPlayingRecording"
endFunction

string function JdbPath_PlayingRecordingName() global
    return ".mcmRecorder.playingRecording.name"
endFunction

string function JdbPath_PlayingRecordingSteps() global
    return ".mcmRecorder.playingRecording.steps"
endFunction

string function JdbPath_PlayingRecordingInlineScript() global
    return ".mcmRecorder.playingRecording.inlineScript"
endFunction

string function JdbPath_PlayingStepFilename() global
    return ".mcmRecorder.playingRecording.stepFilename"
endFunction

string function JdbPath_PlayingStepIndex() global
    return ".mcmRecorder.playingRecording.stepIndex"
endFunction

string function JdbPath_PlayingActionIndex() global
    return ".mcmRecorder.playingRecording.actionIndex"
endFunction

string function JdbPath_PlayingRecordingModName() global
    return ".mcmRecorder.playingRecording.modName"
endFunction

string function JdbPath_PlayingRecordingModPageName() global
    return ".mcmRecorder.playingRecording.pageName"
endFunction

string function JdbPath_PlayingRecordingModsPlayed() global
    return ".mcmRecorder.playingRecording.modsPlayed"
endFunction

string function JdbPath_CurrentlySkippingModName() global
    return ".mcmRecorder.playingRecording.modCurrentlySkipping"
endFunction

string function JdbPath_PlayingRecordingHasBeenCanceled() global
    return ".mcmRecorder.playingRecording.canceled"
endFunction

string function JdbPath_PlayingRecordingIsPaused() global
    return ".mcmRecorder.playingRecording.paused"
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UNUSED (Configuration)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function JdbPath_Config_ShowNotifications() global
    return ".mcmRecorder.config.notifications"
endFunction

string function JdbPath_Config_ShowMessageBoxes() global
    return ".mcmRecorder.config.messageboxes"
endFunction
