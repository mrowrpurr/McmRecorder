scriptName McmRecorder_RecordingInfo hidden

int function Get(string recordingName) global
    return McmRecorder_RecordingFiles.GetRecordingInfo(recordingName)
endFunction

bool function IsAutorun(int recordingInfo) global
    return JMap.getInt(recordingInfo, "autorun")
endFunction
