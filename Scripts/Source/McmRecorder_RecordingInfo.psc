scriptName McmRecorder_RecordingInfo hidden

int function Get(string recordingName) global
    return McmRecorder_RecordingFiles.GetRecordingInfo(recordingName)
endFunction

function Save(string recordingName, int recordingInfo) global
    McmRecorder_RecordingFiles.SaveRecordingInfoFile(recordingName, recordingInfo)
endFunction

bool function IsAutorun(int recordingInfo) global
    return JMap.getStr(recordingInfo, "autorun") == "true" || JMap.getInt(recordingInfo, "autorun") == 1
endFunction

string function GetName(int recordingInfo) global
    return JMap.getStr(recordingInfo, "name")
endFunction

; TODO support replacements like $STEP_COUNT$ or something.
string function GetWelcomeMessage(int recordingInfo) global
    return JMap.getStr(recordingInfo, "welcome")
endFunction

string function GetCompleteMessage(int recordingInfo) global
    return JMap.getStr(recordingInfo, "complete")
endFunction
