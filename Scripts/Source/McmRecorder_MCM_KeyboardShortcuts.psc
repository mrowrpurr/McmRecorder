scriptName McmRecorder_MCM_KeyboardShortcuts hidden

string function PageName() global
    return "Keyboard Shortcuts"
endFunction

function Render(McmRecorderMCM mcmMenu) global
    if McmRecorder_Recorder.AnyRecordings()
        ; Recording Choice Dropdown
        mcmMenu.AddTextOption("Choose a recording to set keyboard shortcut", "", mcmMenu.OPTION_FLAG_DISABLED)
        mcmMenu.AddEmptyOption()
        mcmMenu.oid_KeyboardShortcuts_SelectRecordingMenu = mcmMenu.AddMenuOption("", "[Choose Recording]", mcmMenu.OPTION_FLAG_NONE)
        mcmMenu.AddEmptyOption()

        ; Existing keyboard shortcuts
        Render_KeyboardShortcutInfos(mcmMenu, McmRecorder_KeyboardShortcuts.GetShortcutsInfos())
    else
        mcmMenu.AddTextOption("No recordings available", "", mcmMenu.OPTION_FLAG_DISABLED)
    endIf
endFunction

function Render_KeyboardShortcutInfos(McmRecorderMCM mcmMenu, int shortcutInfos) global
    int shortcutOptions = JIntMap.object()
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_MCM_KeyboardShortcuts_ShortcutOptions(), shortcutOptions, createMissingKeys = true)
    int shortcutInfosCount = JArray.count(shortcutInfos)
    if shortcutInfosCount > 0
        mcmMenu.AddEmptyOption()
        mcmMenu.AddEmptyOption()
        int i = 0
        while i < shortcutInfosCount

            int shortcutInfo = JArray.getObj(shortcutInfos, i)
            string recordingName = JMap.getStr(shortcutInfo, "recordingName")
            int shortcut = JMap.getObj(shortcutInfo, "shortcut")
            int keycode = JMap.getInt(shortcut, "key")

            int keymap = JMap.object()
            JMap.setStr(keymap, "action", "keymap")
            JMap.setObj(keymap, "shortcutInfo", shortcutInfo)

            int ctrl = JMap.object()
            JMap.setStr(ctrl, "action", "ctrl")
            JMap.setObj(ctrl, "shortcutInfo", shortcutInfo)

            int alt = JMap.object()
            JMap.setStr(alt, "action", "alt")
            JMap.setObj(alt, "shortcutInfo", shortcutInfo)

            int shift = JMap.object()
            JMap.setStr(shift, "action", "shift")
            JMap.setObj(shift, "shortcutInfo", shortcutInfo)

            int delete = JMap.object()
            JMap.setStr(delete, "action", "delete")
            JMap.setObj(delete, "shortcutInfo", shortcutInfo)

            JIntMap.setObj(shortcutOptions, mcmMenu.AddKeyMapOption(recordingName, keycode, mcmMenu.OPTION_FLAG_NONE), keymap)
            JIntMap.setObj(shortcutOptions, mcmMenu.AddTextOption("Click to delete Recording", "DELETE", mcmMenu.OPTION_FLAG_NONE), delete)
            JIntMap.setObj(shortcutOptions, mcmMenu.AddToggleOption("Ctrl", JMap.getStr(shortcut, "ctrl") == "true", mcmMenu.OPTION_FLAG_NONE), ctrl)
            mcmMenu.AddEmptyOption()
            JIntMap.setObj(shortcutOptions, mcmMenu.AddToggleOption("Alt", JMap.getStr(shortcut, "alt") == "true", mcmMenu.OPTION_FLAG_NONE), alt)
            mcmMenu.AddEmptyOption()
            JIntMap.setObj(shortcutOptions, mcmMenu.AddToggleOption("Shift", JMap.getStr(shortcut, "shift") == "true", mcmMenu.OPTION_FLAG_NONE), shift)
            mcmMenu.AddEmptyOption()
            mcmMenu.AddEmptyOption()
            mcmMenu.AddEmptyOption()
            i += 1
        endWhile
    endIf
endFunction

function OnOptionSelect(McmRecorderMCM mcmMenu, int optionId) global
    int shortcutInfoAndAction = GetShortcutInfoAndActionForOptionsID(optionId)
    if shortcutInfoAndAction
        string clickAction = JMap.getStr(shortcutInfoAndAction, "action")
        int shortcutInfo = JMap.getObj(shortcutInfoAndAction, "shortcutInfo")
        string recordingName = JMap.getStr(shortcutInfo, "recordingName")
        int recordingInfo = McmRecorder_Recording.Get(recordingName)
        int shortcut = JMap.getObj(recordingInfo, "shortcut")
        if clickAction == "ctrl"
            if JMap.getStr(shortcut, "ctrl") == "true"
                JMap.removeKey(shortcut, "ctrl")
                mcmMenu.SetToggleOptionValue(optionId, false, false)
            else
                JMap.setStr(shortcut, "ctrl", "true")
                mcmMenu.SetToggleOptionValue(optionId, true, false)
            endIf
            McmRecorder_Recording.Save(recordingInfo)
        elseIf clickAction == "alt"
            if JMap.getStr(shortcut, "alt") == "true"
                JMap.removeKey(shortcut, "alt")
                mcmMenu.SetToggleOptionValue(optionId, false, false)
            else
                JMap.setStr(shortcut, "alt", "true")
                mcmMenu.SetToggleOptionValue(optionId, true, false)
            endIf
            McmRecorder_Recording.Save(recordingInfo)
        elseIf clickAction == "shift"
            if JMap.getStr(shortcut, "shift") == "true"
                JMap.removeKey(shortcut, "shift")
                mcmMenu.SetToggleOptionValue(optionId, false, false)
            else
                JMap.setStr(shortcut, "shift", "true")
                mcmMenu.SetToggleOptionValue(optionId, true, false)
            endIf
            McmRecorder_Recording.Save(recordingInfo)
        elseIf clickAction == "delete"
            if mcmMenu.ShowMessage("Are you sure you would like to delete this shortcut?", true, "Yes", "Cancel")
                JMap.removeKey(recordingInfo, "shortcut")
                mcmMenu.ForcePageReset()
                McmRecorder_Recording.Save(recordingInfo)
            endIf
        endIf
    endIf
endFunction

function OnOptionKeyMapChange(McmRecorderMCM mcmMenu, int optionId, int keyCode) global
    McmRecorder recorder = McmRecorder.GetMcmRecorderInstance()
    int shortcutInfoAndAction = GetShortcutInfoAndActionForOptionsID(optionId)
    if shortcutInfoAndAction
        int shortcutInfo = JMap.getObj(shortcutInfoAndAction, "shortcutInfo")
        string recordingName = JMap.getStr(shortcutInfo, "recordingName")
        int recordingInfo = McmRecorder_Recording.Get(recordingName)
        int shortcut = JMap.getObj(recordingInfo, "shortcut")
        JMap.setInt(shortcut, "key", keyCode)
        mcmMenu.SetKeyMapOptionValue(optionId, keyCode, false)
        recorder.StopListeningForKeyboardShortcuts()
        McmRecorder_Recording.Save(recordingInfo)
        recorder.StartListenForKeyboardShortcuts()
    endIf
endFunction

function OnOptionMenuOpen(McmRecorderMCM mcmMenu, int optionId) global
    if optionId == mcmMenu.oid_KeyboardShortcuts_SelectRecordingMenu
        mcmMenu.KeyboardShortcuts_RecordingNamesMenu = new string[1]
        string[] recordingNames = McmRecorder_RecordingsFolder.GetRecordingNames()
        int recordingsWithoutShortcutsCount = 0
        int i = 0
        while i < recordingNames.Length
            string recordingName = recordingNames[i]
            if ! JMap.getObj(McmRecorder_Recording.Get(recordingName), "shortcut")
                recordingsWithoutShortcutsCount += 1
                mcmMenu.KeyboardShortcuts_RecordingNamesMenu = Utility.ResizeStringArray(mcmMenu.KeyboardShortcuts_RecordingNamesMenu, recordingsWithoutShortcutsCount)
                mcmMenu.KeyboardShortcuts_RecordingNamesMenu[mcmMenu.KeyboardShortcuts_RecordingNamesMenu.Length - 1] = recordingName
            endIf
            i += 1
        endWhile
        mcmMenu.SetMenuDialogOptions(mcmMenu.KeyboardShortcuts_RecordingNamesMenu)
    endIf
endFunction

function OnOptionMenuAccept(McmRecorderMCM mcmMenu, int optionId, int index) global
    if index == -1
        return
    endIf

    if optionId == mcmMenu.oid_KeyboardShortcuts_SelectRecordingMenu
        string recordingName = mcmMenu.KeyboardShortcuts_RecordingNamesMenu[index]
        McmRecorder_KeyboardShortcuts.AddRecording(recordingName)
        mcmMenu.ForcePageReset()
    endIf
endFunction

int function GetShortcutInfoAndActionForOptionsID(int optionId) global
    int shortcutOptions = JDB.solveObj(McmRecorder_JDB.JdbPath_MCM_KeyboardShortcuts_ShortcutOptions())
    if shortcutOptions
        return JIntMap.getObj(shortcutOptions, optionId)
    endIf
endFunction
