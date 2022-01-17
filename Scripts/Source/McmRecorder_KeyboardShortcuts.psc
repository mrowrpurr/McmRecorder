scriptName McmRecorder_KeyboardShortcuts
{Responsible for MCM Recorder keyboard shortcuts and VR VRIK gestures}

function AddRecording(string recordingName) global
    int recordingInfo = McmRecorder_RecordingInfo.Get(recordingName)
    int shortcut = JMap.getObj(recordingInfo, "shortcut")
    if ! shortcut
        shortcut = JMap.object()
        JMap.setObj(recordingInfo, "shortcut", shortcut)
    endIf
    JMap.setInt(shortcut, "key", -1)
    McmRecorder_RecordingInfo.Save(recordingName, recordingInfo)
endFunction

int function GetShortcutsInfos() global
    string[] recordingNames = McmRecorder_RecordingFiles.GetRecordingNames()
    int shortcutInfos = JArray.object()
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_MCM_KeyboardShortcuts_ShortcutInfos(), shortcutInfos, createMissingKeys = true)
    int i = 0
    while i < recordingNames.Length
        string recordingName = recordingNames[i]
        int recordingInfo = McmRecorder_RecordingInfo.Get(recordingName)
        int shortcut = JMap.getObj(recordingInfo, "shortcut")
        if shortcut
            int shortcutInfo = JMap.object()
            JMap.setStr(shortcutInfo, "recordingName", recordingName)
            JMap.setObj(shortcutInfo, "shortcut", shortcut)
            JArray.addObj(shortcutInfos, shortcutInfo)
        endIf
        i += 1
    endWhile
    return shortcutInfos
endFunction
