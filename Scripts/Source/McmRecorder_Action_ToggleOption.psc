scriptName McmRecorder_Action_ToggleOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "toggle") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int playback, int actionInfo) global

endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, string toggleAction) global

endFunction

