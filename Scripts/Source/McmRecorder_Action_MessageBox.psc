scriptName McmRecorder_Action_MessageBox hidden

bool function IsActionType(int actionInfo, int metaInfo) global
    return McmRecorder_Action.HasKey(actionInfo, "msgbox")
endFunction

function Play(int actionInfo, int metaInfo) global
    string text = McmRecorder_Action.GetString(actionInfo, "msgbox")
    Debug.MessageBox(text)
endFunction
