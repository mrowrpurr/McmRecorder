scriptName McmRecorder_VRIK

string function GetModEventNameForRecording(string recordingName) global
    return "McmRecorder_VrGesture_PlayRecording:" + recordingName
endFunction

string function GetRecordingNameFromModEvent(string modEventName) global
    return StringUtil.Substring(modEventName, StringUtil.GetLength("McmRecorder_VrGesture_PlayRecording:"))
endFunction

bool function IsVrikInstalled() global
    return Game.GetModByName("vrik.esp") != 255
endFunction

function RegisterVrikGesturesForRecordings() global
    string[] recordingNames = McmRecorder_RecordingFiles.GetRecordingNames()
    int i = 0
    while i < recordingNames.Length
        string recordingName = recordingNames[i]
        int recordingInfo = McmRecorder_RecordingInfo.Get(recordingName)
        bool isGesture = McmRecorder_RecordingInfo.IsVrGesture(recordingInfo)
        if isGesture
            RegisterVrikGestureForRecording(recordingName)
        endIf
        i += 1
    endWhile
endFunction

function RegisterVrikGestureForRecording(string recordingName) global
    VRIK.VrikAddGestureAction(GetModEventNameForRecording(recordingName), "MCM Recording: " + recordingName)
    ListenForVriKGestureForRecording(recordingName)
endFunction

function UnregisterVrikGestureForRecording(string recordingName) global
    ; TODO - Looks like there's no way to remove a VRIK gesture action?????
    StopListeningForVriKGestureForRecording(recordingName)
endFunction

function ListenForVriKGesturesForRecordings() global
    string[] recordingNames = McmRecorder_RecordingFiles.GetRecordingNames()
    int i = 0
    while i < recordingNames.Length
        string recordingName = recordingNames[i]
        int recordingInfo = McmRecorder_RecordingInfo.Get(recordingName)
        bool isGesture = McmRecorder_RecordingInfo.IsVrGesture(recordingInfo)
        if isGesture
            ListenForVriKGestureForRecording(recordingName)
        endIf
        i += 1
    endWhile
endFunction

function ListenForVriKGestureForRecording(string recordingName) global
    McmRecorder.GetMcmRecorderInstance().ListenForVriKGestureForRecording(recordingName)
endFunction

function StopListeningForVriKGestureForRecording(string recordingName) global
    McmRecorder.GetMcmRecorderInstance().StopListeningForVriKGestureForRecording(recordingName)
endFunction
