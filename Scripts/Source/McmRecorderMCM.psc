scriptName McmRecorderMCM extends SKI_ConfigBase
{**PRIVATE** Please do not edit.}

McmRecorder Recorder

int oid_Record
int oid_Stop
int[] oids_Recordings
int oid_KeyboardShortcuts_RecordingSelectionMenu

string[] menuOptions
string[] recordings
bool isPlayingRecording
string currentlyPlayingRecordingName
bool openRunOrPreviewStepsPrompt

bool property IsSkyrimVR
    bool function get()
        return Game.GetModByName("SkyrimVR.esm") != 255
    endFunction
endProperty

bool property IsVrikInstalled
    bool function get()
        return McmRecorder_VRIK.IsVrikInstalled()
    endFunction
endProperty

bool property HasJcontainersInstalled
    bool function get()
        return JContainers.APIVersion()
    endFunction
endProperty

bool property HasPapyrusUtilInstalled
    bool function get()
        return PapyrusUtil.GetVersion() 
    endFunction
endProperty

event OnConfigInit()
    ModName = "MCM Recorder"
    Recorder = (self as Quest) as McmRecorder
endEvent

event OnConfigOpen()
    if IsSkyrimVR && IsVrikInstalled
        Pages = new string[3]
        Pages[0] = "MCM Recordings"
        Pages[1] = "Keyboard Shortcuts"
        Pages[2] = "VR Gestures"
    else
        Pages = new string[2]
        Pages[0] = "MCM Recordings"
        Pages[1] = "Keyboard Shortcuts"
    endIf
endEvent

event OnPageReset(string page)
    bool papyrusUtilOK = HasPapyrusUtilInstalled
    bool jcontainersOK = HasJcontainersInstalled

    if papyrusUtilOK && jcontainersOK
        if page == "Keyboard Shortcuts"
            Render_KeyboardShortcuts()
        elseIf page == "VR Gestures"
            Render_VRGestures()
        else
            Render_Recordings()
        endIf
    else
        if ! papyrusUtilOK
            AddTextOption("<font color=\"#ff0000\">PapyrusUtil not found</font>", "<font color=\"#ff0000\">FAILED</font>", OPTION_FLAG_DISABLED)
            AddTextOption("<font color=\"#ff0000\">(or incompatible version installed)</font>", "", OPTION_FLAG_DISABLED)
        endIf
        if ! jcontainersOK
            AddTextOption("<font color=\"#ff0000\">JContainers not found</font>", "<font color=\"#ff0000\">FAILED</font>", OPTION_FLAG_DISABLED)
            AddTextOption("<font color=\"#ff0000\">(or incompatible version installed)</font>", "", OPTION_FLAG_DISABLED)
        endIf
    endIf
endEvent

function Render_Recordings()
    if McmRecorder_Recorder.IsRecording()
        oid_Stop = AddTextOption("Currently Recording!", "STOP RECORDING", OPTION_FLAG_NONE)
        AddTextOption(McmRecorder_Recorder.GetCurrentRecordingName(), "", OPTION_FLAG_DISABLED)
    else
        if IsSkyrimVR
            oid_Record = AddTextOption("Click to begin recording:", "BEGIN RECORDING", OPTION_FLAG_NONE)
        else
            oid_Record = AddInputOption("Click to begin recording:", "BEGIN RECORDING", OPTION_FLAG_NONE)
        endIf
        AddEmptyOption()
    endIf
    ListRecordings()
endFunction

function Render_KeyboardShortcuts()
    if McmRecorder_Recorder.AnyRecordings()
        ; Recording Choice Dropdown
        AddTextOption("Choose a recording to set keyboard shortcut", "", OPTION_FLAG_DISABLED)
        AddEmptyOption()
        oid_KeyboardShortcuts_RecordingSelectionMenu = AddMenuOption("", "[Choose Recording]", OPTION_FLAG_NONE)
        AddEmptyOption()

        ; Existing keyboard shortcuts
        Render_KeyboardShortcutInfos(McmRecorder_KeyboardShortcuts.GetShortcutsInfos())
    else
        AddTextOption("No recordings available", "", OPTION_FLAG_DISABLED)
    endIf
endFunction

function Render_KeyboardShortcutInfos(int shortcutInfos)
    int shortcutOptions = JIntMap.object()
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_MCM_KeyboardShortcuts_ShortcutOptions(), shortcutOptions, createMissingKeys = true)
    int shortcutInfosCount = JArray.count(shortcutInfos)
    if shortcutInfosCount > 0
        AddEmptyOption()
        AddEmptyOption()
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

            JIntMap.setObj(shortcutOptions, AddKeyMapOption(recordingName, keycode, OPTION_FLAG_NONE), keymap)
            JIntMap.setObj(shortcutOptions, AddTextOption("Click to delete Recording", "DELETE", OPTION_FLAG_NONE), delete)
            JIntMap.setObj(shortcutOptions, AddToggleOption("Ctrl", JMap.getStr(shortcut, "ctrl") == "true", OPTION_FLAG_NONE), ctrl)
            AddEmptyOption()
            JIntMap.setObj(shortcutOptions, AddToggleOption("Alt", JMap.getStr(shortcut, "alt") == "true", OPTION_FLAG_NONE), alt)
            AddEmptyOption()
            JIntMap.setObj(shortcutOptions, AddToggleOption("Shift", JMap.getStr(shortcut, "shift") == "true", OPTION_FLAG_NONE), shift)
            AddEmptyOption()
            AddEmptyOption()
            AddEmptyOption()
            i += 1
        endWhile
    endIf
endFunction

int function GetShortcutInfoAndActionForOptionsID(int optionId)
    int shortcutOptions = JDB.solveObj(McmRecorder_JDB.JdbPath_MCM_KeyboardShortcuts_ShortcutOptions())
    if shortcutOptions
        return JIntMap.getObj(shortcutOptions, optionId)
    endIf
endFunction

function Render_VRGestures()
    recordings = McmRecorder_RecordingFiles.GetRecordingNames()
    if recordings.Length && ((! McmRecorder_Recorder.IsRecording()) || recordings.Length > 1)
        SetCursorFillMode(TOP_TO_BOTTOM)
        AddTextOption("Choose MCM Recordings", "", OPTION_FLAG_DISABLED)
        AddTextOption("These will become available as VRIK Gestures", "", OPTION_FLAG_DISABLED)
        AddTextOption("which can be configured via the VRIK MCM", "", OPTION_FLAG_DISABLED)
        AddEmptyOption()
        SetCursorFillMode(LEFT_TO_RIGHT)
        oids_Recordings = Utility.CreateIntArray(recordings.Length)
        int i = 0
        while i < recordings.Length
            string recordingName = recordings[i]
            if recordingName != McmRecorder_Recorder.GetCurrentRecordingName()
                string[] stepNames = McmRecorder_RecordingFiles.GetRecordingStepFilenames(recordingName)
                int recordingInfo = McmRecorder_RecordingFiles.GetRecordingInfo(recordingName)
                bool isGesture = McmRecorder_RecordingInfo.IsVrGesture(recordingInfo)
                oids_Recordings[i] = AddToggleOption(recordingName, isGesture, OPTION_FLAG_NONE)
                string authorText = ""
                if JMap.getStr(recordingInfo, "author")
                    authorText = "by " + JMap.getStr(recordingInfo, "author")
                endIf
                AddTextOption(authorText, JMap.getStr(recordingInfo, "version"), OPTION_FLAG_DISABLED)
            endIf
            i += 1
        endWhile
    else
        AddTextOption("There are no recordings", "", OPTION_FLAG_DISABLED)
    endIf
endFunction

function ListRecordings()
    recordings = McmRecorder_RecordingFiles.GetRecordingNames()
    if recordings.Length && ((! McmRecorder_Recorder.IsRecording()) || recordings.Length > 1)
        AddEmptyOption()
        AddEmptyOption()
        AddTextOption("Choose a recording to play:", "", OPTION_FLAG_DISABLED)
        AddEmptyOption()
        oids_Recordings = Utility.CreateIntArray(recordings.Length)
        int i = 0
        while i < recordings.Length
            string recordingName = recordings[i]
            if recordingName != McmRecorder_Recorder.GetCurrentRecordingName()
                string[] stepNames = McmRecorder_RecordingFiles.GetRecordingStepFilenames(recordingName)
                oids_Recordings[i] = AddTextOption("", recordingName, OPTION_FLAG_NONE)
                int recordingInfo = McmRecorder_RecordingFiles.GetRecordingInfo(recordingName)
                string authorText = ""
                if JMap.getStr(recordingInfo, "author")
                    authorText = "by " + JMap.getStr(recordingInfo, "author")
                endIf
                AddTextOption(authorText, JMap.getStr(recordingInfo, "version"), OPTION_FLAG_DISABLED)
            endIf
            i += 1
        endWhile
    endIf
endFunction

event OnOptionSelect(int optionId)
    if IsSkyrimVR && optionId == oid_Record ; SkyrimVR
        if ! McmRecorder_Recorder.IsRecording()
            McmRecorder_Recorder.BeginRecording(GetRandomRecordingName())
            ForcePageReset()
        else
            McmRecorder_Recorder.StopRecording() ; For SkyrimVR these OIDs are the same
            ForcePageReset()
        endIf
    elseIf optionId == oid_Stop
        McmRecorder_Recorder.StopRecording()
        ForcePageReset()
    elseIf oids_Recordings.Find(optionId) > -1
        int recordingIndex = oids_Recordings.Find(optionId)
        string recordingName = recordings[recordingIndex]
        if CurrentPage == "VR Gestures"
            int recording = McmRecorder_RecordingInfo.Get(recordingName)
            bool isGesture = McmRecorder_RecordingInfo.IsVrGesture(recording)
            if isGesture
                McmRecorder_RecordingInfo.SetIsVrGesture(recording, false)
                SetToggleOptionValue(optionId, false, false)
                McmRecorder_VRIK.UnregisterVrikGestureForRecording(recordingName)
            else
                McmRecorder_RecordingInfo.SetIsVrGesture(recording, true)
                SetToggleOptionValue(optionId, true, false)
                McmRecorder_VRIK.RegisterVrikGestureForRecording(recordingName)
            endIf
        else
            PromptToRunRecordingOrPreviewSteps(recordingName)
        endIf
    else
        int shortcutInfoAndAction = GetShortcutInfoAndActionForOptionsID(optionId)
        if shortcutInfoAndAction
            string clickAction = JMap.getStr(shortcutInfoAndAction, "action")
            int shortcutInfo = JMap.getObj(shortcutInfoAndAction, "shortcutInfo")
            string recordingName = JMap.getStr(shortcutInfo, "recordingName")
            int recordingInfo = McmRecorder_RecordingInfo.Get(recordingName)
            int shortcut = JMap.getObj(recordingInfo, "shortcut")
            if clickAction == "ctrl"
                if JMap.getStr(shortcut, "ctrl") == "true"
                    JMap.removeKey(shortcut, "ctrl")
                    SetToggleOptionValue(optionId, false, false)
                else
                    JMap.setStr(shortcut, "ctrl", "true")
                    SetToggleOptionValue(optionId, true, false)
                endIf
                McmRecorder_RecordingInfo.Save(recordingName, recordingInfo)
            elseIf clickAction == "alt"
                if JMap.getStr(shortcut, "alt") == "true"
                    JMap.removeKey(shortcut, "alt")
                    SetToggleOptionValue(optionId, false, false)
                else
                    JMap.setStr(shortcut, "alt", "true")
                    SetToggleOptionValue(optionId, true, false)
                endIf
                McmRecorder_RecordingInfo.Save(recordingName, recordingInfo)
            elseIf clickAction == "shift"
                if JMap.getStr(shortcut, "shift") == "true"
                    JMap.removeKey(shortcut, "shift")
                    SetToggleOptionValue(optionId, false, false)
                else
                    JMap.setStr(shortcut, "shift", "true")
                    SetToggleOptionValue(optionId, true, false)
                endIf
                McmRecorder_RecordingInfo.Save(recordingName, recordingInfo)
            elseIf clickAction == "delete"
                if ShowMessage("Are you sure you would like to delete this shortcut?", true, "Yes", "Cancel")
                    JMap.removeKey(recordingInfo, "shortcut")
                    ForcePageReset()
                    McmRecorder_RecordingInfo.Save(recordingName, recordingInfo)
                endIf
            endIf
        endIf
    endIf
endEvent

event OnOptionKeyMapChange(int optionId, int keyCode, string conflictControl, string conflictName)
    int shortcutInfoAndAction = GetShortcutInfoAndActionForOptionsID(optionId)
    if shortcutInfoAndAction
        int shortcutInfo = JMap.getObj(shortcutInfoAndAction, "shortcutInfo")
        string recordingName = JMap.getStr(shortcutInfo, "recordingName")
        int recordingInfo = McmRecorder_RecordingInfo.Get(recordingName)
        int shortcut = JMap.getObj(recordingInfo, "shortcut")
        JMap.setInt(shortcut, "key", keyCode)
        SetKeyMapOptionValue(optionId, keyCode, false)
        Recorder.StopListeningForKeyboardShortcuts()
        McmRecorder_RecordingInfo.Save(recordingName, recordingInfo)
        Recorder.StartListenForKeyboardShortcuts()
    endIf
endEvent

event OnOptionInputAccept(int optionId, string text)
    McmRecorder_Recorder.BeginRecording(text)
    ForcePageReset()
    Debug.MessageBox("Recording Started!\n\nYou can now interact with MCM menus and all interactions will be recorded.\n\nWhen you are finished, return to this page to stop the recording (or quit the game).\n\nRecordings are saved in simple text files inside of Data\\McmRecorder\\ which you can edit to tweak your recording without completely re-recording it :)")
endEvent

event OnOptionInputOpen(int optionId)
    if optionId == oid_Record
        SetInputDialogStartText(GetRandomRecordingName())
    endIf
endEvent

event OnOptionMenuOpen(int optionId)
    if optionId == oid_KeyboardShortcuts_RecordingSelectionMenu
        menuOptions = new string[1]
        string[] recordingNames = McmRecorder_RecordingFiles.GetRecordingNames()
        int recordingsWithoutShortcutsCount = 0
        int i = 0
        while i < recordingNames.Length
            string recordingName = recordingNames[i]
            if ! JMap.getObj(McmRecorder_RecordingInfo.Get(recordingName), "shortcut")
                recordingsWithoutShortcutsCount += 1
                menuOptions = Utility.ResizeStringArray(menuOptions, recordingsWithoutShortcutsCount)
                menuOptions[menuOptions.Length - 1] = recordingName
            endIf
            i += 1
        endWhile
        SetMenuDialogOptions(menuOptions)
    endIf
endEvent

event OnOptionMenuAccept(int optionId, int index)
    if index == -1
        return
    endIf

    if optionId == oid_KeyboardShortcuts_RecordingSelectionMenu
        string recordingName = menuOptions[index]
        McmRecorder_KeyboardShortcuts.AddRecording(recordingName)
        ForcePageReset()
    endIf
endEvent

string function GetRandomRecordingName()
    string[] currentTimeParts = StringUtil.Split(Utility.GetCurrentRealTime(), ".")
    return "Recording_" + currentTimeParts[0] + "_" + currentTimeParts[1]
endFunction

; TODO move to the McmRecorder maybe a global script for prompts
function PromptToRunRecordingOrPreviewSteps(string recordingName)
    string recordingDescription = McmRecorder_RecordingFiles.GetRecordingDescription(recordingName)

    bool confirmation = true

    ; The ShowMessage prompt can not be interacted with via SkyrimVR so we simply show a prompt - not a confirmation dialog
    if ! IsSkyrimVR
        confirmation = ShowMessage(recordingDescription + "\n\nClose the MCM to continue\n\nYou will be prompted to play this recording\n\nYou will also be able to preview all recording steps or play individual one\n\nYou will also be given the opportunity to continue the recording\n\nWould you like to continue?", "No", "Yes", "Cancel")
        if confirmation
            Debug.MessageBox("Close the MCM to continue")
        endIf
    endIf

    if confirmation
        string[] stepNames = McmRecorder_RecordingFiles.GetRecordingStepFilenames(recordingName)
        string text = recordingDescription + "\n"
        int i = 0
        while i < stepNames.Length && i < 11
            if i == 10
                text += "\n- ..."
            else
                text += "\n- " + StringUtil.Substring(stepNames[i], 0, StringUtil.Find(stepNames[i], ".json"))
            endIf
            i += 1
        endWhile
        text += "\n\nWould you like to play this recording?"

        ; Inlined to extract method later
        Recorder.McmRecorder_MessageText.SetName(text)
        int responseId = Recorder.McmRecorder_Message_RunRecordingOrViewSteps.Show()
        string response
        if responseId == 0
            response = "Play Recording"
        elseIf responseId == 1
            response = "View Steps"
        elseIf responseId == 2
            response = "Add to Recording"
        elseIf responseId == 3
            response = "Cancel"
        endIf

        if response == "Play Recording"
            currentlyPlayingRecordingName = recordingName
            isPlayingRecording = true
            McmRecorder_Player.PlayRecording(recordingName)
            currentlyPlayingRecordingName = ""
            isPlayingRecording = false
        elseIf response == "View Steps"
            ShowStepSelectionUI(recordingName, stepNames)
        elseIf response == "Add to Recording"
            McmRecorder_Recorder.ContinueRecording(recordingName)
            Debug.MessageBox("Recording has been restarted!\n\nYou can now interact with MCM menus and all interactions will be recorded.\n\nWhen you are finished, return to the MCM Recorder mod configuration menu to stop the recording (or quit the game).\n\nRecordings are saved in simple text files inside of Data\\McmRecorder\\ which you can edit to tweak your recording without completely re-recording it :)")
        endIf
    endIf
endFunction

function ShowStepSelectionUI(string recordingName, string[] stepNames)
    UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
    menu.AddEntryItem("[" + recordingName + "]")
    menu.AddEntryItem(" ")

    int i = 0
    while i < stepNames.Length
        string stepName = stepNames[i]
        menu.AddEntryItem(stepName)
        i += 1
    endWhile

    menu.OpenMenu()

    int selection = menu.GetResultInt()

    if selection < 2 ; Go Back
        ; TODO open the previous prompt! This isn't working...
        ; PromptToRunRecordingOrPreviewSteps(recordingName)
    else
        int stepIndex = selection - 2 ; Subtract the top 3 entry items
        string stepName = stepNames[stepIndex]
        McmRecorder_Player.PlayStep(recordingName, stepName)
        Debug.MessageBox("MCM recording " + recordingName + " step " + StringUtil.Substring(stepName, 0, StringUtil.Find(stepName, ".json")) + " has finished playing.")
    endIf
endFunction
