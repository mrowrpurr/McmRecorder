scriptName McmRecorder_McmFields hidden
{Responsible for storage of and querying of individual fields on Mod Configuration Menu pages}

function TrackField(string modName, string pageName, string optionType, int optionId, string text, string strValue, float fltValue, string stateName, bool force = false) global
	if force || McmRecorder.IsRecording() || McmRecorder.IsPlayingRecording()
        int optionsOnModPageForType = OptionsForModPage_ByOptionType(modName, pageName, optionType)
        int option = JMap.object()
        JArray.addObj(optionsOnModPageForType, option)
        JMap.setObj(OptionsForModPage_ByOptionIds(modName, pageName), optionId, option)
        JMap.setInt(option, "id", optionId)
        JMap.setStr(option, "state", stateName)
        JMap.setStr(option, "type", optionType)
        JMap.setStr(option, "text", text)
        JMap.setStr(option, "strValue", strValue)
        JMap.setFlt(option, "fltValue", fltvalue)
	endIf
endFunction

function ResetMcmOptions() global
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_McmOptions(), JMap.object(), createMissingKeys = true)
endFunction

int function GetConfigurationOptionById(string modName, string pageName, int optionId) global
    return JMap.getObj(OptionsForModPage_ByOptionIds(modName, pageName), optionId)
endFunction

int function OptionsForModPage_ByOptionIds(string modName, string pageName) global
    return JMap.getObj(OptionsForModPage(modName, pageName), "byId")
endFunction

int function OptionsForModPage_ByOptionTypes(string modName, string pageName) global
    return JMap.getObj(OptionsForModPage(modName, pageName), "byType")
endFunction

int function OptionsForModPage_ByOptionType(string modName, string pageName, string optionType) global
    int byType = OptionsForModPage_ByOptionTypes(modName, pageName)
    int typeMap = JMap.getObj(byType, optionType)
    if ! typeMap
        typeMap = JArray.object()
        JMap.setObj(byType, optionType, typeMap)
    endIf
    return typeMap
endFunction

int function OptionsForModPage(string modName, string pageName) global
    if ! pageName
        pageName = "SKYUI_DEFAULT_PAGE"
    endIf
    int options = JDB.solveObj(McmRecorder_JDB.JdbPath_ModConfigurationOptionsForPage(modName, pageName))
    if ! options
        options = JMap.object()
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_ModConfigurationOptionsForPage(modName, pageName), options, createMissingKeys = true)
        JMap.setObj(options, "byId", JMap.object())
        JMap.setObj(options, "byType", JMap.object())
    endIf
    return options
endFunction

; Given the internal numerical identifier for field types used by SkyUI in mod configuration menus,
; return a text representation of the field type, e.g. "input" rather than 8
string function GetOptionTypeName(int skyUiMcmOptiontype) global
    if skyUiMcmOptiontype == 0
        return "empty"
    elseIf skyUiMcmOptiontype == 1
        return "header"
    elseIf skyUiMcmOptiontype == 2
        return "text"
    elseIf skyUiMcmOptiontype == 3
        return "toggle"
    elseIf skyUiMcmOptiontype == 4
        return "slider"
    elseIf skyUiMcmOptiontype == 5
        return "menu"
    elseIf skyUiMcmOptiontype == 6
        return "color"
    elseIf skyUiMcmOptiontype == 7
        return "keymap"
    elseIf skyUiMcmOptiontype == 8
        return "input"
    else
        return "unknown"
    endIf
endFunction

int function GetSelectorIndex(string modName, string pageName, string optionType, string selector, int optionId, string stateName) global
    int options = OptionsForModPage_ByOptionType(modName, pageName, optionType)
    int optionCount = JArray.count(options)
    int index = -1
    int count = 0
    int i = 0

    while i < optionCount
        int option = JArray.getObj(options, i)

        ; Right hand side text case when the left-hand-side text is blank
        if JMap.getStr(option, "type") == "text" && (!JMap.getStr(option, "text"))
            if JMap.getStr(option, "strValue") == selector
                count += 1
            endIf
            ; Just check the left-hand-side text per usual
        elseIf JMap.getStr(option, "text") == selector
            count += 1
        endIf

        ; Is this the specific option?
        string thisOptionState = JMap.getStr(option, "state")
        int thisOptionId = JMap.getInt(option, "id")
        if thisOptionState && thisOptionState == stateName
            index = count ; the current matching index
        elseIf thisOptionId && thisOptionId == optionId
            index = count ; the current matching index
        endIf

        i += 1
    endWhile

    Debug.MessageBox("COUNT " + modName + " " + pageName + " " + selector + " " + optionId + " " + stateName + " : " + index + " (" + count + ")")

    if count > 1
        return index
    else
        return -1
    endIf
endFunction
