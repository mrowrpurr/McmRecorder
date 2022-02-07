scriptName McmRecorder_Action_MenuOption hidden

bool function IsActionType(int actionInfo) global
    return (JMap.hasKey(actionInfo, "choose") || JMap.hasKey(actionInfo, "chooseIndex")) && JMap.hasKey(actionInfo, "option")
endFunction

function Play(int playback, int actionInfo) global

endFunction

function PerformAction_ByName(SKI_ConfigBase mcmMenu, int option, string menuOptionName) global

endFunction

function PerformAction_ByIndex(SKI_ConfigBase mcmMenu, int option, int menuOptionIndex) global

endFunction
