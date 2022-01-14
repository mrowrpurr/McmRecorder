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
; Form used to set dynamic text in all of the Message dialogs used by MCM Recorder.
Form property McmRecorder_MessageText auto

; **PRIVATE**
;
; Stores the installed version of MCM Recorder. Used for performing version upgrades.
string property CurrentlyInstalledVersion auto

; Returns the installed version of MCM Recorder
string function GetVersion() global
    return "1.0.3"
endFunction

event OnInit()
    CurrentlyInstalledVersion = GetVersion()
    skiConfigManager = Quest.GetQuest("SKI_ConfigManagerInstance") as SKI_ConfigManager
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
; Recording
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Returns true if a recording is currently in progress.
;
; Note: this is for recording not playback. Check `IsPlayingRecording()` for playback.
bool function IsRecording() global
    return McmRecorder_Recorder.GetCurrentRecordingName()
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Playback
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Returns true if a recording is currently being played.
;
; Note: this will also return true if any step or action is being played.
bool function IsPlayingRecording() global
    return JDB.solveInt(McmRecorder_JDB.JdbPath_IsPlayingRecording())
endFunction
