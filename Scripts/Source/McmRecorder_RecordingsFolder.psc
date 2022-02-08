scriptName McmRecorder_RecordingsFolder hidden

function Reload() global
    int recordingNamesToFilePaths = GetNewTempStoredMapForLoadingFiles()

    string[] allRecordingFilePaths = RecordingFilePaths()

    int recordingFilePathIndex = 0
    while recordingFilePathIndex < allRecordingFilePaths.Length
        string filepath = allRecordingFilePaths[recordingFilePathIndex]
        int loadedFile = JValue.readFromFile(filepath)
        if loadedFile && JMap.hasKey(loadedFile, "name")
            string recordingName = JMap.getStr(loadedFile, "name")
            JMap.setStr(recordingNamesToFilePaths, recordingName, filepath)
        endIf
        recordingFilePathIndex += 1
    endWhile

    UpdateRecordingNamesToFilePaths(recordingNamesToFilePaths)
endFunction

string function GetRecordingFilePath(string recordingName) global
    return JMap.getStr(RecordingNamesToFilePaths(), recordingName)
endFunction

string[] function GetRecordingNames() global
    return JMap.allKeysPArray(RecordingNamesToFilePaths())
endFunction

string[] function RecordingFilePaths() global
    string[] paths = JContainers.contentsOfDirectoryAtPath(McmRecorder_Files.GetMcmRecordingsDataPath(), ".json")
    string mcmRecorderConfigPath = McmRecorder_Files.GetMcmRecorderConfigurationFilePath()
    if paths.Find(mcmRecorderConfigPath) > -1
        string[] pathsWithoutMcmRecorderConfig = Utility.CreateStringArray(paths.Length - 1)
        int i = 0
        int newIndex = 0
        while i < paths.Length - 1
            if paths[i] != mcmRecorderConfigPath
                pathsWithoutMcmRecorderConfig[newIndex] = paths[i]
                newIndex += 1
            endIf
            i += 1
        endWhile
        return pathsWithoutMcmRecorderConfig
    else
        return paths
    endIf
endFunction

int function RecordingNamesToFilePaths() global
    int map = JDB.solveObj(McmRecorder_JDB.JdbPath_RecordingFilePaths())
    if ! map
        map = JMap.object()
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_RecordingFilePaths(), map, createMissingKeys = true)
    endIf
    return map
endFunction

function UpdateRecordingNamesToFilePaths(int map) global
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_RecordingFilePaths(), map, createMissingKeys = true)
endFunction

int function GetNewTempStoredMapForLoadingFiles() global
    int map = JMap.object()
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_RecordingFilePaths_Loading(), map, createMissingKeys = true)
    return map
endFunction
