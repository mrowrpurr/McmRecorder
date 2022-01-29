scriptName McmRecorder_KeyboardShortcuts
{Responsible for MCM Recorder keyboard shortcuts and VR VRIK gestures}

function AddRecording(string recordingName) global
    int recordingInfo = McmRecorder_Recording.Get(recordingName)
    int shortcut = JMap.getObj(recordingInfo, "shortcut")
    if ! shortcut
        shortcut = JMap.object()
        JMap.setObj(recordingInfo, "shortcut", shortcut)
    endIf
    JMap.setInt(shortcut, "key", -1)
    McmRecorder_Recording.Save(recordingInfo)
endFunction

int function GetShortcutsInfos() global
    string[] recordingNames = McmRecorder_Files.GetRecordingNames()
    int shortcutInfos = JArray.object()
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_MCM_KeyboardShortcuts_ShortcutInfos(), shortcutInfos, createMissingKeys = true)
    int i = 0
    while i < recordingNames.Length
        string recordingName = recordingNames[i]
        int recordingInfo = McmRecorder_Recording.Get(recordingName)
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

int[] function GetAllKeyboardShortcutKeys() global
    int[] keycodes
    string[] recordingNames = McmRecorder_Files.GetRecordingNames()
    int shortcutInfos = JArray.object()
    int i = 0
    while i < recordingNames.Length
        string recordingName = recordingNames[i]
        int recordingInfo = McmRecorder_Recording.Get(recordingName)
        int shortcut = JMap.getObj(recordingInfo, "shortcut")
        if shortcut
            int keycode = JMap.getInt(shortcut, "key")
            if keycodes.Find(keycode) == -1
                keycodes = Utility.ResizeIntArray(keycodes, keycodes.Length + 1)
                keycodes[keycodes.Length - 1] = keycode
            endIf
        endIf
        i += 1
    endWhile
    return keycodes
endFunction

function RunKeyboardShortcutIfAny(int pressedKey) global
    bool ctrlPressed = Input.IsKeyPressed(29)  || Input.IsKeyPressed(157)
    bool altPressed  = Input.IsKeyPressed(56)  || Input.IsKeyPressed(184)
    bool shiftPressed = Input.IsKeyPressed(42) || Input.IsKeyPressed(54)
    bool found
    string[] recordingNames = McmRecorder_Files.GetRecordingNames()
    int shortcutInfos = JArray.object()
    int i = 0
    while i < recordingNames.Length && (!found)
        string recordingName = recordingNames[i]
        int recording = McmRecorder_Recording.Get(recordingName)
        int shortcut = JMap.getObj(recording, "shortcut")
        if shortcut
            int keycode = JMap.getInt(shortcut, "key")
            bool ctrl = JMap.getStr(shortcut, "ctrl") == "true"
            bool alt = JMap.getStr(shortcut, "alt") == "true"
            bool shift = JMap.getStr(shortcut, "shift") == "true"
            if pressedKey == keycode && \
                ctrlPressed == ctrl && \
                altPressed == alt && \
                shiftPressed == shift
                McmRecorder_Logging.ConsoleOut("[Keyboard Shortcut] " + recordingName + " Key:" + keycode + " Ctrl:" + ctrl + " Alt:" + alt + " Shift:" + shift)
                bool notifications = McmRecorder_Config.ShowNotifications()
                bool messageboxes = McmRecorder_Config.ShowMessageBoxes()
                McmRecorder_Config.SetShowNotifications(false)
                McmRecorder_Config.SetShowMessageBoxes(false)
                McmRecorder_Recording.PlayByName(recordingName)
                McmRecorder_Config.SetShowNotifications(notifications)
                McmRecorder_Config.SetShowMessageBoxes(messageboxes)
                found = true
            endIf
        endIf
        i += 1
    endWhile
endFunction
