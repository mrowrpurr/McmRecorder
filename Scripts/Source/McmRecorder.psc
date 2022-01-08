scriptName McmRecorder extends Quest  

int property CurrentRecordingId auto

SKI_ConfigBase[] property MCMs0 auto
SKI_ConfigBase[] property MCMs1 auto
SKI_ConfigBase[] property MCMs2 auto
SKI_ConfigBase[] property MCMs3 auto
SKI_ConfigBase[] property MCMs4 auto
SKI_ConfigBase[] property MCMs5 auto
SKI_ConfigBase[] property MCMs6 auto
SKI_ConfigBase[] property MCMs7 auto
SKI_ConfigBase[] property MCMs8 auto
SKI_ConfigBase[] property MCMs9 auto

McmRecorder function GetInstance() global
    return Game.GetFormFromFile(0x800, "McmRecorder.esp") as McmRecorder
endFunction

event OnInit()
    ResetMcmMenuInstanceArrays()
endEvent

function ResetMcmMenuInstanceArrays()
    MCMs0 = new SKI_ConfigBase[128]
    MCMs1 = new SKI_ConfigBase[128]
    MCMs2 = new SKI_ConfigBase[128]
    MCMs3 = new SKI_ConfigBase[128]
    MCMs4 = new SKI_ConfigBase[128]
    MCMs5 = new SKI_ConfigBase[128]
    MCMs6 = new SKI_ConfigBase[128]
    MCMs7 = new SKI_ConfigBase[128]
    MCMs8 = new SKI_ConfigBase[128]
    MCMs9 = new SKI_ConfigBase[128]
endFunction

string function PathToRecordings() global
    return "Data/McmRecorder"
endFunction

string function PathToRecordingFile(string recordingName) global
    return PathToRecordings() + "/" + recordingName + ".json"
endFunction

string function JdbPathToRecording(string recordingName) global
    return ".mcmRecorder.recordings." + JdbPathPart(recordingName)
endFunction

string function JdbPathToCurrentRecordingName() global
    return ".mcmRecorder.currentRecordingName"
endFunction

string function JdbPathToModConfigurationOptionsForPage(string modName, string pageName) global
    return ".mcmRecorder.mcmOptions." + JdbPathPart(modName) + "." + JdbPathPart(pageName)
endFunction

string function JdbPathToMcmInstanceIndicies() global
    return ".mcmRecorder.mcmInstanceIndicies"
endFunction

string function JdbPathPart(string part) global
    string[] parts = StringUtil.Split(part, ".")
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
    return sanitized
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

int function GetCurrentRecording() global
    return JDB.solveObj(JdbPathToRecording(GetCurrentRecordingName()))
endFunction

string[] function GetRecordingNames() global
    string[] fileNames = MiscUtil.FilesInFolder(PathToRecordings())
    int i = 0
    while i < fileNames.Length
        fileNames[i] = StringUtil.Substring(fileNames[i], 0, StringUtil.Find(fileNames[i], ".json"))
        i += 1
    endWhile
    return fileNames
endFunction

int function GetMcmInstanceMap() global
    int instanceMap = JDB.solveObj(JdbPathToMcmInstanceIndicies())
    if ! instanceMap
        instanceMap = JMap.object()
        JDB.solveObjSetter(JdbPathToMcmInstanceIndicies(), instanceMap, createMissingKeys = true)
    endIf
    return instanceMap
endFunction

; TODO - add locking here
int function GetNextMcmInstanceIndex(string modName) global
    int index = JMap.count(GetMcmInstanceMap())
    JMap.setObj(GetMcmInstanceMap(), modName, index)
    return index
endFunction

int function GetMcmInstanceIndex(string modName) global
    return JMap.getInt(GetMcmInstanceMap(), modName)
endFunction

function StoreMcmInstance(string modName, SKI_ConfigBase mcm) global
    int instanceIndex = GetNextMcmInstanceIndex(modName)
    McmRecorder recorder = GetInstance()
    if instanceIndex < 128
        recorder.MCMs0[instanceIndex] = mcm
    ; .... TODO ....
    endIf
endFunction

SKI_ConfigBase function GetMcmInstance(string modName) global
    McmRecorder recorder = GetInstance()
    int instanceIndex = GetMcmInstanceIndex(modName)
    if instanceIndex < 128
        return recorder.MCMs0[instanceIndex]
    ; .... TODO ....
    endIf
endFunction

bool function IsRecording() global
    return GetCurrentRecordingName()
endFunction

function Save(string recordingName = "") global
    if ! recordingName
        recordingName = GetCurrentRecordingName()
    endIf
    JValue.writeToFile(JDB.solveObj(JdbPathToRecording(recordingName)), PathToRecordingFile(recordingName))
endFunction

function AddConfigurationOption(string modName, string pageName, int optionId, string optionType, string optionText, string optionStrValue, float optionFltValue) global
    int optionsOnModPageForType = GetModPageConfigurationOptionsForOptionType(modName, pageName, optionType)
    int option = JMap.object()
    JArray.addObj(optionsOnModPageForType, option)
    JMap.setInt(option, "id", optionId)
    JMap.setStr(option, "type", optionType)
    JMap.setStr(option, "text", optionText)
    JMap.setStr(option, "strValue", optionStrValue)
    JMap.setFlt(option, "fltValue", optionFltValue)
    JValue.writeToFile(JDB.solveObj(".mcmRecorder"), "McmOptions.json")
endFunction

int function GetModPageConfigurationOptions(string modName, string pageName) global
    int options = JDB.solveObj(JdbPathToModConfigurationOptionsForPage(modName, pageName))
    if ! options
        options = JMap.object()
        JDB.solveObjSetter(JdbPathToModConfigurationOptionsForPage(modName, pageName), options, createMissingKeys = true)
        JMap.setObj(options, "byType", JMap.object())
    endIf
    return options
endFunction

int function GetModPageConfigurationOptionsForOptionTypes(string modName, string pageName) global
    return JMap.getObj(GetModPageConfigurationOptions(modName, pageName), "byType")
endFunction

int function GetModPageConfigurationOptionsForOptionType(string modName, string pageName, string optionType) global
    int byType = GetModPageConfigurationOptionsForOptionTypes(modName, pageName)
    int typeMap = JMap.getObj(byType, optionType)
    if ! typeMap
        typeMap = JArray.object()
        JMap.setObj(byType, optionType, typeMap)
    endIf
    return typeMap
endFunction

function RecordAction(string modName, string pageName, int index = -1, bool recordFloatValue = false, bool recordStringValue = false, bool recordOptionType = false, float fltValue = -1.0, string strValue = "", string optionType = "") global
    if IsRecording() && modName != "MCM Recorder"
        int mcmAction = JMap.object()
        JArray.addObj(GetCurrentRecording(), mcmAction)
        JMap.setStr(mcmAction, "mod", modName)
        if pageName != "SKYUI_DEFAULT_PAGE"
            JMap.setStr(mcmAction, "page", pageName)
        endIf
        JMap.setInt(mcmAction, "index", index)
        if recordOptionType
            JMap.setStr(mcmAction, "type", optionType)
        endIf
        if recordFloatValue
            JMap.setFlt(mcmAction, "value", fltValue)
        elseIf recordStringValue
            JMap.setStr(mcmAction, "value", strValue)
        endIf
        Save()
    endIf
endFunction

function PlayRecording(string recordingName) global
    int recordingActions = JValue.readFromFile(PathToRecordingFile(recordingName))
    int actionCount = JArray.count(recordingActions)
    int i = 0
    while i < actionCount
        PlayAction(JArray.getObj(recordingActions, i))
        i += 1
    endWhile
endFunction

function PlayAction(int actionInfo) global
    string modName = JMap.getStr(actionInfo, "mod")
    string pageName = JMap.getStr(actionInfo, "page")
    ; string text = JMap.getStr(actionInfo, "text") ; TODO update to store text (instead of option index)
    int optionId = JMap.getInt(actionInfo, "index")
    SKI_ConfigBase mcm = GetMcmInstance(modName)
    Debug.MessageBox("PlayAction " + modName + " " + pageName + " " + optionId + " " + mcm)
endFunction
