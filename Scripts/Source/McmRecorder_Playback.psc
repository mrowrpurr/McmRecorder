scriptName McmRecorder_Playback hidden

int function Create(int recording, string startingStepFilename = "", int startingActionIndex = -1) global
    int this = JMap.object()
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlaybackById(this), this, createMissingKeys = true)
    JMap.setObj(this, "recording", recording)
    if startingStepFilename
        SetCurrentStepFilename(this, startingStepFilename)
    endIf
    if startingActionIndex != -1
        SetCurrentActionIndex(this, startingActionIndex)
    endIf
    if McmRecorder_Recording.HasInlineScript(recording)
        JMap.setObj(this, "inlineScript", McmRecorder_Recording.GetInlineScript(recording))
    endIf
    int stepsByFilename = McmRecorder_Recording.StepsByFilename(recording)
    if stepsByFilename
        JMap.setObj(this, "stepsByFilename", stepsByFilename)
    endIf
endFunction

function Play(int this) global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_IsPlaying(this), 1, createMissingKeys = true)
    
    ;
    Debug.MessageBox("PLAYBACK RECORDING " + McmRecorder_Recording.GetName(Recording(this)))

    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_IsPlaying(this), 0)
endFunction

function Resume(int this) global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_IsPlaying(this), 1, createMissingKeys = true)

    ;
    
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_Playback_IsPlaying(this), 0)
endFunction

function Dispose(int this) global
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_PlaybackById(this), 0)
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

string function CurrentPageName(int this) global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_Playback_CurrentModPageName(this))
endFunction

function SetCurrentPageName(int this, string pageName) global
    JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Playback_CurrentModPageName(this), pageName, createMissingKeys = true)
endFunction
