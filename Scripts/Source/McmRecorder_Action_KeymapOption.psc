scriptName McmRecorder_Action_KeymapOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "shortcut") && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int playback, int actionInfo) global

endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, int shortcut) global

endFunction 
