scriptName McmRecorder_TopLevelPlayer hidden

function Play(int recordingId, string startingStepFilename = "", int startingActionIndex = -1) global
    int this = McmRecorder_Playback.Create(recordingId, startingStepFilename, startingActionIndex)
    SetPlaybackId(this)
    McmRecorder_Playback.Play(this)
    if ! IsPaused()
        McmRecorder_Playback.Dispose(this)
    endIf
    SetPlaybackId(0)
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
