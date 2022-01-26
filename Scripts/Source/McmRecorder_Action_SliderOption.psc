scriptName McmRecorder_Action_SliderOption hidden

bool function IsActionType(int actionInfo, int metaInfo) global
    return McmRecorder_Action.HasKey(actionInfo, "slider")
endFunction

function Play(int actionInfo, int metaInfo) global

endFunction
