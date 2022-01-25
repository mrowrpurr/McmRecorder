scriptName McmRecorder_Files hidden
{Responsible for managing the recording files found in Data\McmRecorder\}

string function GetMcmRecordingsDataPath() global
    return "Data/McmRecorder"
endFunction
























;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function SaveCurrentRecording(string recordingName, string modName) global
    JValue.writeToFile(McmRecorder_Recorder.GetCurrentRecordingSteps(), GetFileNameForRecordingAction(recordingName, modName))
endFunction

function SaveRecordingInfoFile(string recordingName, int metaInfo) global
    JValue.writeToFile(metaInfo, PathToRecordingFolder(recordingName) + ".json")
endFunction

int function GetAllStepsForRecording(string recordingName) global
    return JValue.readFromDirectory(PathToRecordingFolder(recordingName))
endFunction

string[] function GetRecordingNames() global
    if ! MiscUtil.FileExists(GetMcmRecordingsDataPath())
        string[] ret
        return ret
    endIf

    string[] fileNames
    
    if McmRecorder_Config.IsSkyrimVR()
        fileNames = JMap.allKeysPArray(JValue.readFromDirectory(GetMcmRecordingsDataPath()))
    else
        fileNames = MiscUtil.FilesInFolder(GetMcmRecordingsDataPath())
    endIf
    
    int i = 0
    while i < fileNames.Length
        fileNames[i] = StringUtil.Substring(fileNames[i], 0, StringUtil.Find(fileNames[i], ".json"))
        i += 1
    endWhile
    return fileNames
endFunction

string[] function GetRecordingStepFilenames(string recordingName) global
    if McmRecorder_Config.IsSkyrimVR()
        return JMap.allKeysPArray(JValue.readFromDirectory(PathToRecordingFolder(recordingName)))
    else
        return MiscUtil.FilesInFolder(PathToRecordingFolder(recordingName))
    endIf 
endFunction

int function GetRecordingInfo(string recordingName) global
    return JValue.ReadFromFile(PathToRecordingFolder(recordingName) + ".json")
endFunction

int function GetRecordingStep(string recordingName, string stepName) global
    return JValue.readFromFile(PathToStepFile(recordingName, stepName))
endFunction

string function PathToRecordingFolder(string recordingName) global
    return GetMcmRecordingsDataPath() + "/" + FileSystemPathPart(recordingName)
endFunction

string function PathToStepFile(string recordingName, string stepName) global
    if StringUtil.Find(stepName, ".json")
        return GetMcmRecordingsDataPath() + "/" + FileSystemPathPart(recordingName) + "/" + stepName
    else
        return GetMcmRecordingsDataPath() + "/" + FileSystemPathPart(recordingName) + "/" + stepName + ".json"
    endIf
endFunction

string function FileSystemPathPart(string part) global
    string[] parts = StringUtil.Split(part, "/")
    string sanitized = ""
    int i = 0
    while i < parts.Length
        if i == 0
            sanitized += parts[i]
        else
            sanitized += "_" + parts[i]
        endIf
        i += 1
    endWhile
    parts = StringUtil.Split(sanitized, "\\")
    sanitized = ""
    i = 0
    while i < parts.Length
        if i == 0
            sanitized += parts[i]
        else
            sanitized += "_" + parts[i]
        endIf
        i += 1
    endWhile
    return sanitized
endFunction

string function GetFileNameForRecordingAction(string recordingName, string modName) global
    string recordingFolder = PathToRecordingFolder(recordingName)
    int recordingStepNumber
    if McmRecorder_Config.IsSkyrimVR()
        recordingStepNumber = JMap.allKeysPArray(JValue.readFromDirectory(recordingFolder)).Length
    else
        recordingStepNumber = MiscUtil.FilesInFolder(recordingFolder).Length
    endIf
    if modName != McmRecorder_Recorder.GetCurrentRecordingModName()
        recordingStepNumber += 1
        McmRecorder_Recorder.SetCurrentRecordingModName(modName)
    endIf
    string filenameNumericPrefix = recordingStepNumber
    while StringUtil.GetLength(filenameNumericPrefix) < 4
        filenameNumericPrefix = "0" + filenameNumericPrefix
    endWhile
    return PathToRecordingFolder(recordingName) + "/" + filenameNumericPrefix + "_" + FileSystemPathPart(modName) + ".json"
endFunction
