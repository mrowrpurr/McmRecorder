scriptName McmRecorder_Action_Play hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "play")
endFunction

function Play(int actionInfo) global

    ; TODO !

    ; int recordingName = JMap.getObj(actionInfo, "play")
    ; int stepName = JMap.getObj(actionInfo, "step")
    ; McmRecorder_Player.PlayRecording(recordingName, stepName)
endFunction
