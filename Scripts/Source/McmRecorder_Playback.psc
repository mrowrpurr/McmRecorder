scriptName McmRecorder_Playback hidden

int function Create(int recording, string startingStepName = "", int startingActionIndex = -1, int parentScript = -1) global
    MiscUtil.PrintConsole("PLAYBACK CREATE " + recording + " parentScript:" + parentScript)

    int this = JMap.object()
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlaybackById(this), this, createMissingKeys = true)
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_Playback_Recording(this), recording, createMissingKeys = true)
    if startingStepName
        SetCurrentStepFilename(this, startingStepName)
    endIf
    if startingActionIndex != -1
        SetCurrentActionIndex(this, startingActionIndex)
    endIf
    if McmRecorder_Recording.HasInlineScript(recording)
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_Playback_InlineScript(this), McmRecorder_Recording.GetInlineScript(recording), createMissingKeys = true)
    endIf
    int stepsByFilename = McmRecorder_Recording.StepsByFilename(recording)
    if stepsByFilename
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_Playback_StepsByFilename(this), stepsByFilename, createMissingKeys = true)
    endIf
    int scriptInstance = SkyScript.Initialize()
    SkyScript.SetVariableObject(scriptInstance, "playback", this)
    JMap.setObj(this, "script", scriptInstance)
    if parentScript != -1
        SkyScript.SetScriptParent(scriptInstance, parentScript)
    endIf
    return this
endFunction

    ; int recording = Recording(this)
    ; string recordingName = McmRecorder_Recording.GetName(recording)
    ; string startingStep = CurrentStepFilename(this)
    ; int startingActionIndex = CurrentActionIndex(this)
    ; int stepsByFilename = StepsByFilename(this)

function Play(int this) global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_IsPlaying(this), 1, createMissingKeys = true)   

    int recording = Recording(this)

    string recordingName = McmRecorder_Recording.GetName(recording)
    string startingStep = CurrentStepFilename(this)
    int startingActionIndex = CurrentActionIndex(this)

    string log = "Start playback of recording '" + recordingName + "'"
    if startingStep
        log += " Starting Step '" + startingStep + "'"
        if startingActionIndex > -1
            log += " (Starting Action #" + startingActionIndex + ")"
        endIf
    endIf
    McmRecorder_Logging.ConsoleOut(log)

    if ShouldPrintNotifications(this)
        McmRecorder_UI.Notification("Play " + recordingName)
    endIf

    SkyScript.SetVariableString(GetScript(this), "recordingName", recordingName)

    _Play_InlineScript(this)
    _Play_Steps(this)

    ; TODO LOG FINISHED

    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_IsPlaying(this), 0)
endFunction

bool function ShouldPrintNotifications(int this) global
    int currentTopLevelPlayback = McmRecorder_TopLevelPlayer.PlaybackId()
    return currentTopLevelPlayback && currentTopLevelPlayback == this
endFunction

int function GetScript(int this) global
    return JMap.getObj(this, "script")
endFunction

function _Play_InlineScript(int this) global
    if IsCanceled(this) || IsPaused(this)
        return
    endIf

    int recording = Recording(this)
    string recordingName = McmRecorder_Recording.GetName(recording)

    int inlineScript = InlineScript(this)
    if inlineScript
        McmRecorder_Logging.ConsoleOut("Playing recording '" + recordingName + "' inline script (" + JArray.count(inlineScript) + " actions)")
        McmRecorder_Action.Play(this, inlineScript)
    endIf
endFunction

function _Play_Steps(int this) global
    if IsCanceled(this) || IsPaused(this)
        return
    endIf

    int recording = Recording(this)
    string recordingName = McmRecorder_Recording.GetName(recording)    
    int stepsByFilename = StepsByFilename(this)
    if stepsByFilename
        string[] stepFilenames = JMap.allKeysPArray(stepsByFilename)
        McmRecorder_Logging.ConsoleOut("Playing recording '" + recordingName + "' steps (" + stepFilenames.Length + " steps)")

        string startingStepName = CurrentStepFilename(this)
        int startingActionindex = CurrentActionIndex(this)
        bool isFirstStep = true
        bool firstStepFound = true
        if startingStepName
            firstStepFound = false
        endIf
        int stepIndex = 0
        while stepIndex < stepFilenames.Length && (! IsCanceled(this)) && (! IsPaused(this))
            string stepFilename = stepFilenames[stepIndex]
            string stepName = McmRecorder_Files.FilenameWithoutExtension(stepFilename, ".json")
            if (! firstStepFound) && startingStepName == stepName
                firstStepFound = true
            endIf
            if firstStepFound
                int stepActions = JMap.getObj(stepsByFilename, stepFilename)
                int stepActionCount = JArray.count(stepActions)
                SetCurrentStepFilename(this, stepFilename)
                SetCurrentStepIndex(this, stepIndex)
                int actionIndex = 0
                while actionindex < stepActionCount && (! IsCanceled(this)) && (! IsPaused(this))
                    bool shouldPlay = (startingActionIndex == -1) ; If no action specified, should play!
                    if ! shouldPlay
                        shouldPlay = ! isFirstStep ; If a specific action was provided but this is no longer the first step, should play!
                    endIf
                    if ! shouldPlay
                        shouldPlay = actionIndex >= startingActionIndex
                    endIf
                    if shouldPlay
                        SetCurrentActionIndex(this, actionindex)
                        int stepAction = JArray.getObj(stepActions, actionIndex)
                        McmRecorder_Action.Play(this, stepAction)
                    endIf
                    actionIndex += 1
                endWhile
            endIf

            stepIndex += 1
        endWhile
    endIf
endFunction

function Resume(int this) global
    Play(this)
endFunction

function Dispose(int this) global
    int playbacks = JDB.solveObj(McmRecorder_JDB.JdbPath_Playbacks())
    if playbacks
        JMap.removeKey(playbacks, this)
    endIf
endFunction

int function Recording(int this) global
    return JDB.solveObj(McmRecorder_JDB.JdbPath_Playback_Recording(this))
endFunction

int function InlineScript(int this) global
    return JDB.solveObj(McmRecorder_JDB.JdbPath_Playback_InlineScript(this))
endFunction

int function StepsByFilename(int this) global
    return JDB.solveObj(McmRecorder_JDB.JdbPath_Playback_StepsByFilename(this))
endFunction

function Pause(int this) global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_IsPaused(this), 1, createMissingKeys = true)
endFunction

function Cancel(int this) global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_IsCanceled(this), 1, createMissingKeys = true)
endFunction

bool function IsPlaying(int this) global
    return JDB.solveInt(McmRecorder_JDB.JdbPath_Playback_IsPlaying(this))
endFunction

bool function IsPaused(int this) global
    return JDB.solveInt(McmRecorder_JDB.JdbPath_Playback_IsPaused(this))
endFunction

bool function IsCanceled(int this) global
    return JDB.solveInt(McmRecorder_JDB.JdbPath_Playback_IsCanceled(this))
endFunction

string function CurrentStepFilename(int this) global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_Playback_CurrentStepFilename(this))
endFunction

function SetCurrentStepFilename(int this, string stepFilename) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Playback_CurrentStepFilename(this), stepFilename, createMissingKeys = true)
endFunction

int function CurrentStepIndex(int this) global
    return JDB.solveInt(McmRecorder_JDB.JdbPath_Playback_CurrentStepIndex(this))
endFunction

function SetCurrentStepIndex(int this, int index) global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_CurrentStepIndex(this), index, createMissingKeys = true)
endFunction

int function CurrentActionIndex(int this) global
    return JDB.solveInt(McmRecorder_JDB.JdbPath_Playback_CurrentActionIndex(this))
endFunction

function SetCurrentActionIndex(int this, int index) global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_CurrentActionIndex(this), index, createMissingKeys = true)
endFunction

string function CurrentModName(int this) global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_Playback_CurrentModName(this))
endFunction

function SetCurrentModName(int this, string modName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Playback_CurrentModName(this), modName, createMissingKeys = true)
endFunction

string function CurrentModPageName(int this) global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_Playback_CurrentModPageName(this))
endFunction

function SetCurrentModPageName(int this, string pageName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Playback_CurrentModPageName(this), pageName, createMissingKeys = true)
endFunction
