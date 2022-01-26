scriptName McmRecorder_Action hidden

function Play(int actionInfo, int metaInfo) global
    if McmRecorder_Action_MessageBox.IsActionType(actionInfo, metaInfo)
        McmRecorder_Action_MessageBox.Play(actionInfo, metaInfo)
    endIf

    JValue.release(metaInfo)
endFunction

bool function HasKey(int actionInfo, string keyName) global
    return JMap.hasKey(actionInfo, keyName)
endFunction

string function GetString(int actionInfo, string keyName) global
    return JMap.getStr(actionInfo, keyName)
endFunction

; TODO add modName, pageName, etc
function PlayList(int actionList) global
    int actionCount = JArray.count(actionList)
    if actionCount
        int i = 0
        while i < actionCount
            int actionInfo = JArray.getObj(actionList, i)
            Play(actionInfo, 0) ; TODO meta into
            i += 1
        endWhile
    endIf
endFunction
