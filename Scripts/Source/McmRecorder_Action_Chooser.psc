scriptName McmRecorder_Action_Chooser hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "chooser")
endFunction

function Play(int playback, int actionInfo) global
    int optionNames = JMap.getObj(actionInfo, "chooser")
    int optionActions = JMap.getObj(actionInfo, "options")
    int optionCount = JArray.count(optionNames)
    UIListMenu listMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
    int i = 0
    while i < optionCount
        string optionName = JArray.getStr(optionNames, i)
        listMenu.AddEntryItem(optionName)
        i += 1
    endWhile
    listMenu.OpenMenu()
    int result = listMenu.GetResultInt()
    string selectedOptionName = "Cancel"
    if result > -1
        selectedOptionName = JArray.getStr(optionNames, result)
    endIf
    if JMap.hasKey(optionActions, selectedOptionName)
        int optionAction = JMap.getObj(optionActions, selectedOptionName)
        McmRecorder_Action.Play(playback, optionAction)
    endIf
endFunction
