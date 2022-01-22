scriptName McmRecorder extends Quest hidden

; TODO separate out an McmRecorderPrivate so this can become just a public API intended for integration

; **PRIVATE**
;
; Primary instance of the SKI_ConfigManager from the SKI_ConfigManagerInstance quest
SKI_ConfigManager property skiConfigManager auto

; **PRIVATE**
;
; Message used to ask the user if they want to run a full recording, view steps, or add to the recording.
Message property McmRecorder_Message_RunRecordingOrViewSteps auto

; **PRIVATE**
;
; Message used to ask the user if they want to skip a field that wasn't found, retry it, or skip the entire mod.
Message property McmRecorder_Message_SelectorNotFound auto

; **PRIVATE**
;
; Message used to ask the user if they want to skip a mod or wait for it to show up when a mod cannot be found
Message property McmRecorder_Message_ModNotFound auto

; **PRIVATE**
;
; Form used to set dynamic text in all of the Message dialogs used by MCM Recorder.
Form property McmRecorder_MessageText auto

; **PRIVATE**
;
; Stores the installed version of MCM Recorder. Used for performing version upgrades.
string property CurrentlyInstalledVersion auto

; Returns the installed version of MCM Recorder
string function GetVersion() global
    return "1.0.7"
endFunction

event OnInit()
    CurrentlyInstalledVersion = GetVersion()
    skiConfigManager = Quest.GetQuest("SKI_ConfigManagerInstance") as SKI_ConfigManager
    StartListenForKeyboardShortcuts()
    ListenForRaceMenuClose()
    McmRecorder_VRIK.RegisterVrikGesturesForRecordings()
    ListenForRecordingSkseModEvents()
    McmRecorder_McmWatcher.ListenForMcmsToWatch()
endEvent

event SaveGameLoaded()
    RegisterForSingleUpdate(5)
    StartListenForKeyboardShortcuts()
    McmRecorder_VRIK.ListenForVriKGesturesForRecordings()
    ListenForRecordingSkseModEvents()
    McmRecorder_McmWatcher.ListenForMcmsToWatch()
endEvent

function StartListenForKeyboardShortcuts()
    int[] keycodes = McmRecorder_KeyboardShortcuts.GetAllKeyboardShortcutKeys()
    int i = 0
    while i < keycodes.Length
        RegisterForKey(keycodes[i])
        i += 1
    endWhile
endFunction

function StopListeningForKeyboardShortcuts()
    int[] keycodes = McmRecorder_KeyboardShortcuts.GetAllKeyboardShortcutKeys()
    int i = 0
    while i < keycodes.Length
        UnregisterForKey(keycodes[i])
        i += 1
    endWhile
endFunction

event OnKeyDown(int keycode)
    if ! McmRecorder_Player.IsPlayingRecording()
        McmRecorder_KeyboardShortcuts.RunKeyboardShortcutIfAny(keycode)
    endIf
endEvent

; **DO NOT USE THIS**
;
; Returns a **private** script containing the script fields and properties used by MCM Recorder
McmRecorder function GetMcmRecorderInstance() global
    return Quest.GetQuest("McmRecorder") as McmRecorder
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get SkyUI MCM Script Instance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SKI_ConfigBase function GetMcmInstance(string modName) global
    McmRecorder recorder = McmRecorder.GetMcmRecorderInstance()
    int index = recorder.skiConfigManager.ModNames.Find(modName)
    return recorder.skiConfigManager.ModConfigs[index]
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Autorun
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function ListenForRaceMenuClose()
    RegisterForMenu("RaceSex Menu")
endFunction

event OnMenuClose(string menuName)
    if menuName == "RaceSex Menu"
        UnregisterForMenu("RaceSex Menu")
        AutorunRecordings()
    endIf
endEvent

function AutorunRecordings()
    string[] recordingNames = McmRecorder_RecordingFiles.GetRecordingNames()
    int i = 0
    while i < recordingNames.Length
        string recordingName = recordingNames[i]
        int recordingInfo = McmRecorder_RecordingInfo.Get(recordingName)
        if McmRecorder_RecordingInfo.IsAutorun(recordingInfo) && (! McmRecorder_Player.HasBeenAutorun(recordingName))
            McmRecorder_Player.MarkHasBeenAutorun(recordingName)
            McmRecorder_Logging.Log("Autorun Recording " + recordingName)
            McmRecorder_Player.PlayRecording(recordingName, mcmLoadWaitTime = 30.0)
        endIf
        i += 1
    endWhile
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pause and Cancel Running Recording
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function ListenForSystemMenuOpen()
    UnregisterForMenu("Journal Menu")  
    RegisterForMenu("Journal Menu") ; Track when the menu opens so we can show a mesasge if a recording is playing
endFunction

function StopListeningForSystemMenuOpen()
    UnregisterForMenu("Journal Menu")  
endFunction

event OnMenuOpen(string menuName)
    if menuName == "Journal Menu"
        if McmRecorder_Player.IsPlayingRecording()
            McmRecorder_UI.OpenSystemMenuDuringRecordingMessage(McmRecorder_Player.GetCurrentlyPlayingRecordingName())
        endIf
    endIf
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VR Gestures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function ListenForVriKGestureForRecording(string recordingName)
    string modEventName = McmRecorder_VRIK.GetModEventNameForRecording(recordingName)
    RegisterForModEvent(modEventName, "OnVrikGesture")
endFunction

function StopListeningForVriKGestureForRecording(string recordingName)
    string modEventName = McmRecorder_VRIK.GetModEventNameForRecording(recordingName)
    UnregisterForModEvent(modEventName)
endFunction

event OnVrikGesture(string eventName, string strArg, float fltArg, Form sender)
    string recordingName = McmRecorder_VRIK.GetRecordingNameFromModEvent(eventName)
    McmRecorder_Player.PlayRecording(recordingName, verbose = false)
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VR Gestures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function ListenForRecordingSkseModEvents()
    RegisterForModEvent("McmRecorder_PlayRecording", "OnRecordingModEvent")
endFunction

event OnRecordingModEvent(string eventName, string recordingName, float fltArg, Form sender)
    McmRecorder_Player.PlayRecording(recordingName, verbose = false)
endEvent
