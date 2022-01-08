scriptName McmRecorder extends Quest  

int property CurrentRecordingId auto
SKI_ConfigManager property skiConfigManager auto

McmRecorder function GetInstance() global
    return Game.GetFormFromFile(0x800, "McmRecorder.esp") as McmRecorder
endFunction

event OnInit()
    skiConfigManager = Game.GetFormFromFile(0x802, "SkyUI_SE.esp") as SKI_ConfigManager
endEvent

string function PathToRecordings() global
    return "Data/McmRecorder"
endFunction

string function PathToRecordingFolder(string recordingName) global
    return PathToRecordings() + "/" + FileSystemPathPart(recordingName)
endFunction

string function JdbPathToCurrentRecordingName() global
    return ".mcmRecorder.currentRecording.recordingName"
endFunction

string function JdbPathToCurrentRecordingModName() global
    return ".mcmRecorder.currentRecording.currentModName"
endFunction

string function JdbPathToCurrentRecordingRecordingStep() global
    return ".mcmRecorder.currentRecording.currentModStep"
endFunction

string function JdbPathToModConfigurationOptionsForPage(string modName, string pageName) global
    return ".mcmRecorder.mcmOptions." + JdbPathPart(modName) + "." + JdbPathPart(pageName)
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

function BeginRecording(string recordingName) global
    int recordingSteps = JArray.object()
    SetCurrentRecordingName(recordingName)
    SetCurrentRecordingModName("")
    ResetCurrentRecordingSteps()
endFunction

function StopRecording() global
    SetCurrentRecordingName("")
endFunction

string function GetCurrentRecordingName() global
    return JDB.solveStr(JdbPathToCurrentRecordingName())
endFunction

function SetCurrentRecordingName(string recodingName) global
    JDB.solveStrSetter(JdbPathToCurrentRecordingName(), recodingName, createMissingKeys = true)
endFunction

string function GetCurrentRecordingModName() global
    return JDB.solveStr(JdbPathToCurrentRecordingMOdName())
endFunction

function SetCurrentRecordingModName(string modName) global
    JDB.solveStrSetter(JdbPathToCurrentRecordingModName(), modName , createMissingKeys = true)
endFunction

int function GetCurrentRecordingSteps() global
    return JDB.solveObj(JdbPathToCurrentRecordingRecordingStep())
endFunction

function SetCurrentRecordingSteps(int stepInfo) global
    JDB.solveObjSetter(JdbPathToCurrentRecordingRecordingStep(), stepInfo, createMissingKeys = true)
endFunction

function ResetCurrentRecordingSteps() global
    SetCurrentRecordingSteps(JArray.object())
endFunction

string function GetFileNameForRecordingAction(string recordingName, string modName) global
    string recordingFolder = PathToRecordingFolder(recordingName)
    int recordingStepNumber = MiscUtil.FilesInFolder(recordingFolder).Length
    if modName != GetCurrentRecordingModName()
        recordingStepNumber += 1
        SetCurrentRecordingModName(modName)
    endIf
    string filenameNumericPrefix = recordingStepNumber
    while StringUtil.GetLength(filenameNumericPrefix) < 4
        filenameNumericPrefix = "0" + filenameNumericPrefix
    endWhile
    return PathToRecordingFolder(recordingName) + "/" + filenameNumericPrefix + "_" + FileSystemPathPart(modName) + ".json"
endFunction

string[] function GetRecordingNames() global
    string[] fileNames = MiscUtil.FoldersInFolder(PathToRecordings())
    int i = 0
    while i < fileNames.Length
        fileNames[i] = StringUtil.Substring(fileNames[i], 0, StringUtil.Find(fileNames[i], ".json"))
        i += 1
    endWhile
    return fileNames
endFunction

SKI_ConfigBase function GetMcmInstance(string modName) global
    McmRecorder recorder = GetInstance()
    int index = recorder.skiConfigManager._modNames.Find(modName)
    return recorder.skiConfigManager._modConfigs[index]
endFunction

bool function IsRecording() global
    return GetCurrentRecordingName()
endFunction

function Save(string recordingName, string modName) global
    JValue.writeToFile(GetCurrentRecordingSteps(), GetFileNameForRecordingAction(recordingName, modName))
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

function RecordAction(string modName, string pageName, int optionId = -1, string stateName = "", bool recordFloatValue = false, bool recordStringValue = false, bool recordOptionType = false, float fltValue = -1.0, string strValue = "", string optionType = "") global
    if IsRecording() && modName != "MCM Recorder"
        if modName != GetCurrentRecordingModName()
            ResetCurrentRecordingSteps()
        endIf
        int mcmAction = JMap.object()
        JArray.addObj(GetCurrentRecordingSteps(), mcmAction)
        JMap.setStr(mcmAction, "mod", modName)
        if pageName != "SKYUI_DEFAULT_PAGE"
            JMap.setStr(mcmAction, "page", pageName)
        endIf
        if stateName
            JMap.setStr(mcmAction, "state", stateName)
        else
            JMap.setInt(mcmAction, "optionId", optionId)
        endIf
        if recordOptionType
            JMap.setStr(mcmAction, "type", optionType)
        endIf
        if recordFloatValue
            JMap.setFlt(mcmAction, "value", fltValue)
        elseIf recordStringValue
            JMap.setStr(mcmAction, "value", strValue)
        endIf
        Save(GetCurrentRecordingName(), modName)
    endIf
endFunction

function PlayRecording(string recordingName) global
    string[] stepFiles = MiscUtil.FilesInFolder(PathToRecordingFolder(recordingName))
    int fileIndex = 0
    while fileIndex < stepFiles.Length
        int recordingActions = JValue.readFromFile(PathToRecordingFolder(recordingName) + "/" + stepFiles[i])
        int actionCount = JArray.count(recordingActions)
        int i = 0
        while i < actionCount
            PlayAction(JArray.getObj(recordingActions, i))
            i += 1
        endWhile
        fileIndex += 1
    endWhile
    Debug.MessageBox(recordingName + " has finished playing.")
endFunction

function PlayAction(int actionInfo) global
    string modName = JMap.getStr(actionInfo, "mod")
    string pageName = JMap.getStr(actionInfo, "page")
    string optionType = JMap.getStr(actionInfo, "type")
    float fltValue = JMap.getFlt(actionInfo, "value")
    string strValue = JMap.getStr(actionInfo, "value")
    ; string text = JMap.getStr(actionInfo, "text") ; TODO update to store text (instead of option index)

    int optionId = JMap.getInt(actionInfo, "optionId")
    string stateName = JMap.getStr(actionInfo, "state")

    SKI_ConfigBase mcm = GetMcmInstance(modName)
    ; Debug.MessageBox("PlayAction " + modName + " " + pageName + " " + optionId + " " + mcm)
    
    ; mcm.SetPage(pageName, 0) ; TODO store / get page indicies

    if stateName
        string previousState = mcm.GetState()
        mcm.GotoState(stateName)
        if optionType == "menu"
            mcm.OnMenuAcceptST(fltValue as int)
        elseIf optionType == "slider"
            mcm.OnSliderAcceptST(fltValue)
        elseIf optionType == "keymap"
            mcm.OnKeyMapChangeST(fltValue as int, "", "")
        elseIf optionType == "color"
            mcm.OnColorAcceptST(fltValue as int)
        elseIf optionType == "input"
            mcm.OnInputAcceptST(strValue)
        elseIf optionType == "" || optionType == "text"
            mcm.OnSelectST()
        endIf
        mcm.GotoState(previousState)
    else
        if optionType == "menu"
            mcm.OnOptionMenuAccept(optionId, fltValue as int)
        elseIf optionType == "slider"
            mcm.OnOptionSliderAccept(optionId, fltValue)
        elseIf optionType == "keymap"
            mcm.OnOptionKeyMapChange(optionId, fltValue as int, "", "")
        elseIf optionType == "color"
            mcm.OnOptionColorAccept(optionId, fltValue as int)
        elseIf optionType == "input"
            mcm.OnOptionInputAccept(optionId, strValue)
        elseIf optionType == "" || optionType == "text"
            mcm.OnOptionSelect(optionId)
        endIf
    endIf
endFunction
