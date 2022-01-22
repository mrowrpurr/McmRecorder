scriptName McmRecorder_JDB hidden
{Get JDB paths for JDB data stored by MCM Recorder}

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

string function JdbPath_McmOptions() global
    return ".mcmRecorder.mcmOptions"
endFunction

string function JdbPath_McmOptions_MarkForReset() global
    return ".mcmRecorder.McmOptionsShouldBeReset"
endFunction

string function JdbPath_IsPlayingRecording() global
    return ".mcmRecorder.isPlayingRecording"
endFunction

string function JdbPath_PlayingRecordingName() global
    return ".mcmRecorder.playingRecording.name"
endFunction

string function JdbPath_PlayingRecordingSteps() global
    return ".mcmRecorder.playingRecording.steps"
endFunction

string function JdbPath_PlayingStepFilename() global
    return ".mcmRecorder.playingRecording.stepFilename"
endFunction

string function JdbPath_PlayingStepIndex() global
    return ".mcmRecorder.playingRecording.stepIndex"
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

string function JdbPath_AutorunHistory() global
    return ".mcmRecorder.autorunHistory"
endFunction

string function JdbPath_MCM_KeyboardShortcuts_ShortcutInfos() global
    return ".mcmRecorder.mcm.keyboardShortcuts.shortcutInfos"
endFunction

string function JdbPath_MCM_KeyboardShortcuts_ShortcutOptions() global
    return ".mcmRecorder.mcm.keyboardShortcuts.shortcutOptions"
endFunction

string function JdbPath_Config_ShowNotifications() global
    return ".mcmRecorder.config.notifications"
endFunction

string function JdbPath_Config_ShowMessageBoxes() global
    return ".mcmRecorder.config.messageboxes"
endFunction

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
