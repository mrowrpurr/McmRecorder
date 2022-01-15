scriptName McmRecorder_RecordingInfo hidden

int function Get(string recordingName) global
    return McmRecorder_RecordingFiles.GetRecordingInfo(recordingName)
endFunction

bool function IsAutorun(int recordingInfo) global
    return JMap.getStr(recordingInfo, "autorun") == "true" || JMap.getInt(recordingInfo, "autorun") == 1
endFunction
