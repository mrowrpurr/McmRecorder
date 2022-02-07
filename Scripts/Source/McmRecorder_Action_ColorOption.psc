scriptName McmRecorder_Action_ColorOption hidden

bool function IsActionType(int actionInfo) global
    return JMap.hasKey(actionInfo, "color") && JMap.hasKey(actionInfo, "option")
endFunction

; !!!!!!!!! TODO ! Support HTML hexadecimal !!!!!!!!!! And save using hex as well !!!!!!!

function Play(int playback, int actionInfo) global

endFunction

function PerformAction(SKI_ConfigBase mcmMenu, int option, int color) global

endFunction
