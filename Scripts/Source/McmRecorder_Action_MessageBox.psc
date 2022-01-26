scriptName McmRecorder_Action_MessageBox hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "msgbox")
endFunction

function Play(int actionInfo) global
    string text = JMap.getStr(actionInfo, "msgbox")
    Debug.MessageBox(text)
endFunction
