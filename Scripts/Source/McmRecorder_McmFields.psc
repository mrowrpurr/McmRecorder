scriptName McmRecorder_McmFields hidden
{Responsible for storage of and querying of individual fields on Mod Configuration Menu pages}

; TODO OptionsForModPage_ByState & GetConfigurationOptionByState ? O[tion IDs fine for stateful options?

function TrackField(string modName, string pageName, string optionType, int optionId, string text, string strValue, float fltValue, string stateName, bool force = false) global
    if McmOptionsShouldBeReset()
        ResetMcmOptions()
    endIf

	if force || McmRecorder_Recorder.IsRecording() || McmRecorder_Player.IsPlayingRecording()
        int optionsOnModPageForType = OptionsForModPage_ByOptionType(modName, pageName, optionType)
        int option = JMap.object()
        JArray.addObj(optionsOnModPageForType, option)
        JIntMap.setObj(OptionsForModPage_ByOptionIds(modName, pageName), optionId, option)
        JMap.setInt(option, "id", optionId)
        JMap.setStr(option, "state", stateName)
        JMap.setStr(option, "type", optionType)
        JMap.setStr(option, "text", text)
        JMap.setStr(option, "strValue", strValue)
        JMap.setFlt(option, "fltValue", fltvalue)
	endIf
endFunction

function MarkMcmOptionsForReset() global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_McmOptions_MarkForReset(), 1, createMissingKeys = true)
endFunction

function UnMarkMcmOptionsForReset() global
    JDB.solveIntSetter(McmRecorder_JDB.JdbPath_McmOptions_MarkForReset(), 0)
endFunction

bool function McmOptionsShouldBeReset() global
    return JDB.solveInt(McmRecorder_JDB.JdbPath_McmOptions_MarkForReset()) == 1
endFunction

function ResetMcmOptions() global
    UnMarkMcmOptionsForReset()
    JDB.solveObjSetter(McmRecorder_JDB.JdbPath_McmOptions(), JMap.object(), createMissingKeys = true)
endFunction

int function GetConfigurationOptionById(string modName, string pageName, int optionId) global
    return JIntMap.getObj(OptionsForModPage_ByOptionIds(modName, pageName), optionId)
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

int function AllMcmOptions() global
    int options = JDB.solveObj(McmRecorder_JDB.JdbPath_McmOptions())
    if ! options
        options = JMap.object()
        JDB.solveObjSetter(McmRecorder_JDB.JdbPath_McmOptions(), options, createMissingKeys = true)
    endIf
    return options
endFunction

int function OptionsForMod(string modName) global
    int allOptions = AllMcmOptions()
    int options = JMap.getObj(allOptions, modName)
    if ! options
        options = JMap.object()
        JMap.setObj(allOptions, modName, options)
    endIf
    return options
endFunction

int function OptionsForModPage(string modName, string pageName) global
    int modOptions = OptionsForMod(modName)
    if ! pageName
        pageName = "SKYUI_DEFAULT_PAGE"
    endIf
    int options = JMap.getObj(modOptions, pageName)
    if ! options
        options = JMap.object()
        JMap.setObj(modOptions, pageName, options)
        JMap.setObj(options, "byId", JIntMap.object())
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

int function GetSelectorIndex(string modName, string pageName, int optionId) global
    int option = GetConfigurationOptionById(modName, pageName, optionId)

    if ! option
        McmRecorder_Logging.Log("Did not find option with ID " + optionId)
        return -2
    endIf

    string selector = GetOptionSelector(option)
    string stateName = JMap.getStr(option, "state")

    int optionsToSearch = OptionsForModPage_ByOptionType(modName, pageName, JMap.getStr(option, "type"))
    int optionsToSearchCount = JArray.count(optionsToSearch)

    int index = -1 ; The index of the item to return (-1 means it's the only one with the selector on the page)
    int count = 0
    
    int i = 0
    while i < optionsToSearchCount && index == -1
        int optionOnPage = JArray.getObj(optionsToSearch, i)
        string optionOnPageSelector = GetOptionSelector(optionOnPage)

        if optionOnPageSelector == selector
            count += 1
        endIf

        if stateName
            if stateName == JMap.getStr(optionOnPage, "state")
                index = count ; This is this specific item
            endIf
        elseIf optionId == JMap.getInt(optionOnPage, "id") 
            index = count ; This is this specific item
        endIf

        i += 1
    endWhile

    if count > 1
        return index
    else
        return -1
    endIf
endFunction

string function GetOptionSelector(int option) global
    string selector = JMap.getStr(option, "text")
    if ! selector && JMap.getStr(option, "type") == "text" ; Use the 'right' side
        selector = JMap.getStr(option, "strValue")
    endIf
    return selector
endFunction

string function GetWildcardMatcher(string selector) global
    int strLength = StringUtil.GetLength(selector)
    if StringUtil.Substring(selector, 0, 1) == "*" && StringUtil.Substring(selector, strLength - 1, 1) == "*"
        return StringUtil.Substring(selector, 1, strLength - 2)
    else
        return ""
    endIf
endFunction
