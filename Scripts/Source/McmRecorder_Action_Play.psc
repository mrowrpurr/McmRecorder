scriptName McmRecorder_Action_Play hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "play")
endFunction

function Play(int playback, int actionInfo) global
    string recordingName = JMap.getStr(actionInfo, "play")
    string stepName = JMap.getStr(actionInfo, "step")
    McmRecorder_Recording.PlayByName(recordingName, stepName)
endFunction
