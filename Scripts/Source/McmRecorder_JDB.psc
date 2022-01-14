scriptName McmRecorder_JDB hidden
{Get JDB paths for JDB data stored by MCM Recorder}

string function JdbPath_CurrentRecordingName() global
    return ".mcmRecorder.currentRecording.recordingName"
endFunction

string function JdbPath_CurrentRecordingModName() global
    return ".mcmRecorder.currentRecording.currentModName"
endFunction

string function JdbPath_CurrentRecordingRecordingStep() global
    return ".mcmRecorder.currentRecording.currentModStep"
endFunction

string function JdbPath_McmOptions() global
    return ".mcmRecorder.mcmOptions"
endFunction

string function JdbPath_ModConfigurationOptionsForPage(string modName, string pageName) global
    return JdbPath_McmOptions() + "." + JdbPathPart(modName) + "." + JdbPathPart(pageName)
endFunction

string function JdbPath_IsPlayingRecording() global
    return ".mcmRecorder.isPlayingRecording"
endFunction

string function JdbPath_PlayingRecordingModName() global
    return ".mcmRecorder.playingRecording.modName"
endFunction

string function JdbPath_PlayingRecordingModPageName() global
    return ".mcmRecorder.playingRecording.pageName"
endFunction

string function JdbPath_CurrentlySkippingModName() global
    return ".mcmRecorder.playingRecording.modCurrentlySkipping"
endFunction

string function JdbPath_AutorunHistory() global
    return ".mcmRecorder.autorunHistory"
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
