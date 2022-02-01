scriptName McmRecorder_TopLevelPlayer hidden

function PlayByName(string recordingName) global
    int recording = McmRecorder_Recording.Get(recordingName)
    if recording
        Play(recording)
    endIf
endFunction

function Play(int recordingId, string startingStepName = "", int startingActionIndex = -1) global
    int this = McmRecorder_Playback.Create(recordingId, startingStepName, startingActionIndex)
    string recordingName = McmRecorder_Recording.GetName(recordingId)

    ; Tell system that recording is in progress
    McmRecorder recorder = McmRecorder.GetMcmRecorderInstance()
    recorder.ListenForSystemMenuOpen()
    recorder.McmRecorder_Var_IsRecordingCurrentlyPlaying.Value = 1 ; <--- used for UI messageboxes

    SetPlaybackId(this)
    McmRecorder_Playback.Play(this)
    if ! IsPaused()
        McmRecorder_Playback.Dispose(this)
    endIf
    SetPlaybackId(0)

    ; Tell system that recording is no longer in progress
    recorder.StopListeningForSystemMenuOpen()
    recorder.McmRecorder_Var_IsRecordingCurrentlyPlaying.Value = 0 ; <--- used for UI messageboxes

    if ! IsPaused()
        McmRecorder_UI.FinishedMessage(recordingName)
    endIf
endFunction

function Pause() global
    McmRecorder_Playback.Pause(PlaybackId())
endFunction

function Cancel() global
    McmRecorder_Playback.Cancel(PlaybackId())
endFunction

function Resume() global
    McmRecorder_Playback.Resume(PlaybackId())
endFunction

bool function IsRunning() global
    return PlaybackId()
endFunction

bool function IsPlaying() global
    return McmRecorder_Playback.IsPlaying(PlaybackId())
endFunction

bool function IsCanceled() global
    return McmRecorder_Playback.IsCanceled(PlaybackId())
endFunction

bool function IsPaused() global
    return McmRecorder_Playback.IsPaused(PlaybackId())
endFunction

int function PlaybackId() global
    return JDB.solveObj(McmRecorder_JDB.JdbPath_TopLevelPlaybackId())
endFunction

function SetPlaybackId(int playbackId) global
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_TopLevelPlaybackId(), playbackId, createMissingKeys = true)
endFunction

int function Recording() global
    int playbackId = PlaybackId()
    if playbackId
        int recording = McmRecorder_Playback.Recording(playbackId)
        if recording
            return recording
        endIf
    endIf
endFunction

string function RecordingName() global
    int playbackId = PlaybackId()
    if playbackId
        int recording = McmRecorder_Playback.Recording(playbackId)
        if recording
            return Mcmrecorder_Recording.GetName(recording)
        endIf
    endIf
endFunction
