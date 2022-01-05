scriptName McmRecorderMCM extends SKI_ConfigBase

McmRecorder Recorder

event OnConfigInit()
    ModName = "MCM Recorder"
    Recorder = (self as Quest) as McmRecorder
endEvent

event OnPageReset(string page)
    if Recorder.IsRecording
        AddTextOption("Currently Recording", "PAUSE", OPTION_FLAG_NONE)
    else
        AddTextOption("Begin Recording", "RECORD", OPTION_FLAG_NONE)
    endIf
endEvent
