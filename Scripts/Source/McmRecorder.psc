scriptName McmRecorder extends Quest  

int property CurrentRecordingId auto

string function PathToRecordingFile(string recordingName) global
    return "Data/McmRecorder/" + recordingName + ".json"
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

; function OnOptionSelect(SKI_ConfigBase mcm, int optionId) global
;     if IsRecording()
;         Debug.MessageBox("Clicked on option " + optionId + " of mod " + mcm.ModName + " page " + mcm.CurrentPage)
;         Debug.MessageBox("Type: " + mcm._optionTypeBuf[optionId])
;         Debug.MessageBox("Text: " + mcm._textBuf[optionId])
;     endIf
; endFunction
