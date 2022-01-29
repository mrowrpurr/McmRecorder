scriptName McmRecorder_Player hidden
{Responsible for playback of recordings or can trigger individual actions}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO - Move everything OUT of here, then maybe some back in...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
















; bool function IsPlayingRecording() global
;     return JDB.solveInt(McmRecorder_JDB.JdbPath_IsPlayingRecording())
; endFunction

; function Reset() global
;     ClearModsPlayed()
;     MarkRecordingAsPlaying()
;     ResetCurrentPlaybackCancelation()
;     ResetCurrentPlaybackPaused()
;     McmRecorder_McmFields.ResetMcmOptions()
;     SetCurrentPlayingRecordingModName("")
;     SetCurrentPlayingRecordingModPageName("")
;     SetCurrentlyPlayingStepFilename("") ; Make this StepName NOT StepFilename :)
;     SetCurrentlyPlayingStepIndex(-1)
;     SetCurrentlyPlayingActionIndex(-1)
; endFunction

; function PlayRecording(string recordingName, string startingStep = "", int startingActionIndex = -1, float waitTimeBetweenActions = 0.0, float mcmLoadWaitTime = 0.0, bool verbose = true, bool reset = true) global
;     if reset
;         Reset()
;     endIf

;     string startingConsoleMessage = "Playing recording: " + recordingName
;     if startingStep
;         startingConsoleMessage += " Step: " + startingStep
;         if startingActionIndex > -1
;             startingConsoleMessage += " (action " + startingActionIndex + ")"
;         endIf
;     endIf
;     McmRecorder_Logging.ConsoleOut(startingConsoleMessage)

;     SetIsPlayingRecording(true)
;     SetCurrentlyPlayingRecordingName(recordingName)

;     McmRecorder recorder = McmRecorder.GetMcmRecorderInstance()
;     recorder.ListenForSystemMenuOpen()
;     recorder.McmRecorder_Var_IsRecordingCurrentlyPlaying.Value = 1

;     int steps = McmRecorder_Files.ReadStepFilesToMap(recordingName)
;     SetCurrentlyPlayingSteps(steps)

;     string[] stepFiles = JMap.allKeysPArray(steps)

;     if verbose
;         McmRecorder_UI.WelcomeMessage(recordingName)
;         McmRecorder_UI.Notification("Play " + recordingName + " (" + stepFiles.Length + " steps)")
;     endIf

;     bool isFirstStep = true
;     bool firstStepFound = true
;     if startingStep
;         firstStepFound = false
;     endIf

;     int recordingInfo = McmRecorder_Recording.Get(recordingName)
;     SetCurrentlyPlayingInlineScript(recordingInfo)
    
;     ; Inline Script
;     if McmRecorder_Recording.HasInlineScript(recordingInfo)
;         int script = McmRecorder_Recording.GetInlineScript(recordingInfo)
;         SetCurrentlyPlayingInlineScript(script)
;         McmRecorder_Recording.RunInlineScript(script)
;     endIf

;     ; McmRecorder_Recording.RunSteps(recordingInfo) ; <=== TODO XXX

;     ;; TODO - extract Step File Playing

;     int fileIndex = 0
;     while fileIndex < stepFiles.Length && (! IsCurrentRecordingCanceled()) && (! IsCurrentRecordingPaused())

;         ; File for a given step
;         string filename = stepFiles[fileIndex]
;         string stepName = StringUtil.Substring(filename, 0, StringUtil.Find(filename, ".json"))

;         ; Check if this is the first step - used when a starting step is provided
;         if (! firstStepFound) && startingStep == stepName
;             firstStepFound = true
;         endIf

;         if firstStepFound
;             int recordingActions = JMap.getObj(steps, filename)
;             int actionCount = JArray.count(recordingActions)

;             ; Set the current step being run...
;             SetCurrentlyPlayingStepFilename(filename)
;             SetCurrentlyPlayingStepIndex(fileIndex)

;             ; Show notification for the current step being run
;             if verbose
;                 McmRecorder_UI.Notification(filename + " (" + (fileIndex + 1) + "/" + stepFiles.Length + ")")
;             endIf

;             McmRecorder_Logging.ConsoleOut("Play Step: " + stepName)

;             int i = 0
;             while i < actionCount && (! IsCurrentRecordingCanceled()) && (! IsCurrentRecordingPaused())
;                 bool shouldPlay = (startingActionIndex == -1) ; If no action specified, should play!
;                 if ! shouldPlay
;                     shouldPlay = ! isFirstStep ; If a specific action was provided but this is no longer the first step, should play!
;                 endIf
;                 if ! shouldPlay
;                     shouldPlay = i >= startingActionIndex
;                 endIf
;                 if shouldPlay
;                     SetCurrentlyPlayingActionIndex(i)
;                     int recordingAction = JArray.getObj(recordingActions, i)
;                     McmRecorder_Action.Play(recordingAction)
;                     if waitTimeBetweenActions
;                         Utility.WaitMenuMode(waitTimeBetweenActions)
;                     endIf
;                 endIf
;                 i += 1
;             endWhile

;             isFirstStep = false
;         endIf

;         fileIndex += 1
;     endWhile

;     recorder.StopListeningForSystemMenuOpen()

;     if verbose
;         if IsCurrentRecordingCanceled()
;             McmRecorder_UI.Notification("Canceled " + recordingName)
;         elseIf IsCurrentRecordingPaused()
;             McmRecorder_UI.Notification("Paused " + recordingName)
;         else
;             McmRecorder_UI.Notification("Finished " + recordingName)
;             McmRecorder_UI.FinishedMessage(recordingName)
;         endIf
;     endIf

;     if IsCurrentRecordingCanceled()
;         McmRecorder_Logging.ConsoleOut("Recording canceled: " + recordingName)
;     elseIf IsCurrentRecordingPaused()
;         McmRecorder_Logging.ConsoleOut("Recording paused: " + recordingName)
;     else
;         McmRecorder_Logging.ConsoleOut("Recording finished: " + recordingName)
;     endIf

;     MarkRecordingAsNotPlaying()
;     SetIsPlayingRecording(false)
;     recorder.McmRecorder_Var_IsRecordingCurrentlyPlaying.Value = 0

;     if IsCurrentRecordingPaused()
;         McmRecorder_UI.MessageBox("Recording has been paused.")
;     endIf

;     ; Add config that will do this automatically!
;     if McmRecorder_Config.IsDebugMode()
;         McmRecorder_Logging.DumpAll()
;     endIf
; endFunction

; TODO move to McmRecorder_Step
; function PlayStep(string recordingName, string stepName, float waitTimeBetweenActions = 0.0) global
;     SetCurrentlyPlayingStepIndex(-1) ; Dunno! Uh oh! Should we pass this?
;     SetCurrentlyPlayingStepFilename(stepName + ".json") ; TODO XXX Make this track STEP NAME not the Filename
;     SetCurrentPlayingRecordingModName("")
;     SetCurrentPlayingRecordingModPageName("")
;     SetIsPlayingRecording(true) ; XXX is this used?

;     int stepInfo = McmRecorder_Files.GetRecordingStep(recordingName, stepName)
;     JValue.retain(stepInfo)

;     McmRecorder_UI.Notification("Playing step " + stepName + " of recording " + recordingName)
    
;     int actionCount = JArray.count(stepInfo)
;     int i = 0
;     while i < actionCount
;         int recordingAction = JArray.getObj(stepInfo, i)
;         McmRecorder_Action.Play(recordingAction)
;         if waitTimeBetweenActions
;             Utility.WaitMenuMode(waitTimeBetweenActions)
;         endIf
;         i += 1
;     endWhile
    
;     JValue.release(stepInfo)
;     SetIsPlayingRecording(false)
; endFunction

; function ResumeCurrentRecording() global
;     string pausedRecordingName = GetCurrentlyPlayingRecordingName()
;     McmRecorder_Logging.ConsoleOut("Resume recording: " + pausedRecordingName)
;     McmRecorder_UI.Notification("Resume recording: " + pausedRecordingName)
;     string pausedStepFilename = GetCurrentlyPlayingStepFilename()
;     string pausedStepName = StringUtil.Substring(pausedStepFilename, 0, StringUtil.Find(pausedStepFilename, ".json"))
;     int pausedActionIndex = GetCurrentlyPlayingActionIndex()
;     ResetCurrentPlaybackPaused()
;     ; PlayRecording(pausedRecordingName, pausedStepName, pausedActionIndex + 1, reset = false)
; endFunction

; function CancelCurrentRecording() global
;     string pausedRecordingName = GetCurrentlyPlayingRecordingName()
;     McmRecorder_Logging.ConsoleOut("Canceled recording: " + pausedRecordingName)
;     McmRecorder_UI.Notification("Canceled recording: " + pausedRecordingName)
;     Reset()
; endFunction

; function SetIsPlayingRecording(bool running = true) global
;     JDB.solveIntSetter(McmRecorder_JDB.JdbPath_IsPlayingRecording(), running as int, createMissingKeys = true)
; endFunction

; function SetCurrentlyPlayingRecordingName(string recordingName) global
;     JDB.solveStrSetter(McmRecorder_JDB.JdbPath_PlayingRecordingName(), recordingName, createMissingKeys = true)
; endFunction

; string function GetCurrentlyPlayingRecordingName() global
;     return JDB.solveStr(McmRecorder_JDB.JdbPath_PlayingRecordingName())
; endFunction

; function SetCurrentlyPlayingSteps(int steps) global
;     JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlayingRecordingSteps(), steps, createMissingKeys = true)
; endFunction

; int function GetCurrentlyPlayingSteps() global
;     return JDB.solveObj(McmRecorder_JDB.JdbPath_PlayingRecordingSteps())
; endFunction

; function SetCurrentlyPlayingInlineScript(int script) global
;     JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlayingRecordingInlineScript(), script, createMissingKeys = true)
; endFunction

; int function GetCurrentlyPlayingInlineScript() global
;     return JDB.solveObj(McmRecorder_JDB.JdbPath_PlayingRecordingInlineScript())
; endFunction

; function SetCurrentlyPlayingStepFilename(string stepFilename) global
;     JDB.solveStrSetter(McmRecorder_JDB.JdbPath_PlayingStepFilename(), stepFilename, createMissingKeys = true)
; endFunction

; string function GetCurrentlyPlayingStepFilename() global
;     return JDB.solveStr(McmRecorder_JDB.JdbPath_PlayingStepFilename())
; endFunction

; function SetCurrentlyPlayingStepIndex(int stepIndex) global
;     JDB.solveIntSetter(McmRecorder_JDB.JdbPath_PlayingStepIndex(), stepIndex, createMissingKeys = true)
; endFunction

; int function GetCurrentlyPlayingStepIndex() global
;     return JDB.solveInt(McmRecorder_JDB.JdbPath_PlayingStepIndex())
; endFunction

; function SetCurrentlyPlayingActionIndex(int stepIndex) global
;     JDB.solveIntSetter(McmRecorder_JDB.JdbPath_PlayingActionIndex(), stepIndex, createMissingKeys = true)
; endFunction

; int function GetCurrentlyPlayingActionIndex() global
;     return JDB.solveInt(McmRecorder_JDB.JdbPath_PlayingActionIndex())
; endFunction

; string function GetCurrentPlayingRecordingModName() global
;     return JDB.solveStr(McmRecorder_JDB.JdbPath_PlayingRecordingModName())
; endFunction

; function SetCurrentPlayingRecordingModName(string modName) global
;     JDB.solveStrSetter(McmRecorder_JDB.JdbPath_PlayingRecordingModName(), modName , createMissingKeys = true)
; endFunction

; string function GetCurrentPlayingRecordingModPageName() global
;     return JDB.solveStr(McmRecorder_JDB.JdbPath_PlayingRecordingModPageName())
; endFunction

; function SetCurrentPlayingRecordingModPageName(string pageName) global
;     JDB.solveStrSetter(McmRecorder_JDB.JdbPath_PlayingRecordingModPageName(), pageName , createMissingKeys = true)
; endFunction

int function GetModsPlayed() global
    int modsPlayed = JDB.solveObj(McmRecorder_JDB.JdbPath_PlayingRecordingModsPlayed())
    if ! modsPlayed
        modsPlayed = JMap.object()
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlayingRecordingModsPlayed(), modsPlayed, createMissingKeys = true)
    endIf
    return modsPlayed
endFunction

function AddModPlayed(string modName) global
    JMap.setInt(GetModsPlayed(), modName, 1)
endFunction

bool function HasModBeenPlayed(string modName) global
    return JMap.getInt(GetModsPlayed(), modName)
endFunction

bool function ClearModsPlayed() global
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlayingRecordingModsPlayed(), 0)
endFunction

string function GetCurrentlySkippingModName() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_CurrentlySkippingModName())
endFunction

int function GetAutorunHistory() global
    int history = JDB.solveObj(McmRecorder_JDB.JdbPath_AutorunHistory())
    if ! history
        history = JMap.object()
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_AutorunHistory(), history, createMissingKeys = true)
    endIf
    return history
endFunction

bool function HasBeenAutorun(string recordingName) global
    return JMap.getInt(GetAutorunHistory(), recordingName)
endFunction

function MarkHasBeenAutorun(string recordingName) global
    JMap.setInt(GetAutorunHistory(), recordingName, 1)
endFunction

function SetCurrentlySkippingModName(string modName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_CurrentlySkippingModName(), modName, createMissingKeys = true)
endFunction

; function CancelCurrentPlayback() global
;     JDB.solveIntSetter(McmRecorder_JDB.JdbPath_PlayingRecordingHasBeenCanceled(), 1, createMissingKeys = true)
; endFunction

; function ResetCurrentPlaybackCancelation() global
;     JDB.solveIntSetter(McmRecorder_JDB.JdbPath_PlayingRecordingHasBeenCanceled(), 0)
; endFunction

; bool function IsCurrentRecordingCanceled() global
;     return JDB.solveInt(McmRecorder_JDB.JdbPath_PlayingRecordingHasBeenCanceled())
; endFunction

; function PauseCurrentPlayback() global
;     MarkRecordingAsNotPlaying()
;     JDB.solveIntSetter(McmRecorder_JDB.JdbPath_PlayingRecordingIsPaused(), 1, createMissingKeys = true)
; endFunction

; function ResetCurrentPlaybackPaused() global
;     JDB.solveIntSetter(McmRecorder_JDB.JdbPath_PlayingRecordingIsPaused(), 0)
; endFunction

; bool function IsCurrentRecordingPaused() global
;     return JDB.solveInt(McmRecorder_JDB.JdbPath_PlayingRecordingIsPaused())
; endFunction

; function MarkRecordingAsPlaying() global
;     McmRecorder.GetMcmRecorderInstance().McmRecorder_Var_IsRecordingCurrentlyPlaying.Value = 1
; endFunction

; function MarkRecordingAsNotPlaying() global
;     McmRecorder.GetMcmRecorderInstance().McmRecorder_Var_IsRecordingCurrentlyPlaying.Value = 0
; endFunction

function McmMenuNotFound(int playback, int actionInfo, string modName) global
    string result = McmRecorder_UI.GetUserResponseForNotFoundMod(modName)
    if result == "Try again"
        McmRecorder_Action.Play(playback, actionInfo)
    elseIf result == "Skip this mod"
        SetCurrentlySkippingModName(modName)
    endIf
endFunction

function OptionNotFound(int playback, int actionInfo, string modName, string pageName, string optionDescription) global
    string response = McmRecorder_UI.GetUserResponseForNotFoundSelector(modName, pageName, optionDescription)
    if response == "Try again"
        McmRecorder_Action.Play(playback, actionInfo)
    elseIf response == "Skip this mod"
        SetCurrentlySkippingModName(modName)
    endIf
endFunction


