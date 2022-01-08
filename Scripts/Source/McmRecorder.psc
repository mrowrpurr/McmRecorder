scriptName McmRecorder extends Quest  

int property CurrentRecordingId auto

string function PathToRecordingFile(string recordingName) global
    return "Data/McmRecorder/" + recordingName + ".json"
endFunction

string function JdbPathToRecording(string recordingName) global
    return ".mcmRecorder.recordings." + recordingName
endFunction

string function JdbPathToCurrentRecordingName() global
    return ".mcmRecorder.currentRecordingName"
endFunction

function BeginRecording(string recordingName) global
    int recordingSteps = JArray.object()
    JDB.solveObjSetter(JdbPathToRecording(recordingName), recordingSteps, createMissingKeys = true)
    Save(recordingName)
    SetCurrentRecordingName(recordingName)
endFunction

function StopRecording() global
    ;;;;;;
endFunction

string function GetCurrentRecordingName() global
    return JDB.solveStr(JdbPathToCurrentRecordingName())
endFunction

function SetCurrentRecordingName(string recodingName) global
    JDB.solveStrSetter(JdbPathToCurrentRecordingName(), recodingName, createMissingKeys = true)
endFunction

bool function IsRecording() global
    return GetCurrentRecordingName()
endFunction

function Save(string recordingName) global
    JValue.writeToFile(JDB.solveObj(JdbPathToRecording(recordingName)), PathToRecordingFile(recordingName))
    StorageUtil.SetIntValue(None, "MC_IsAwesome", 1)
    ; StorageUtil.GetIntValue(None, )
endFunction

; function GetRecorderData()
;     int data = "Data/McmRecorder/"
; endFunction

; function InitializeMcmMenu(string menuName)

; endFunction

; function AddConfigurationOption(string modName, string pageName, string type, )

function OnOptionSelect(SKI_ConfigBase mcm, int optionId) global
    if IsRecording()
        Debug.MessageBox("CLICK " + optionId + " " + mcm)
    endIf
endFunction
