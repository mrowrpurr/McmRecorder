scriptName McmRecorder_Action_InputOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "text") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int playback, int actionInfo) global

endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, string text) global

endFunction
