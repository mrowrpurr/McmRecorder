scriptName McmRecorder_Config hidden
{Responsible for checking MCM Recorder configuration settings
    
Settings are defined in Data\McmRecorder.json}

float function GetMcmMenuLoadWaitTime() global
    return 10.0
endFunction

float function GetMcmMenuLoadWaitInterval() global
    return 1.0
endFunction

float function GetMcmMenuLoadNotificationInterval() global
    return 5.0
endFunction

























; CURRENTLY UNUSED! ALL BELOW UNUSED ----

function ReloadConfig() global
    ; TODO
endFunction

bool function IsSkyrimVR() global
    return Game.GetModByName("SkyrimVR.esm") != 255
endFunction

bool function ShowNotifications() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_Config_ShowNotifications()) != "false"
endFunction

bool function SetShowNotifications(bool value) global
    if value
        JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Config_ShowNotifications(), "true", createMissingKeys = true)
    else
        JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Config_ShowNotifications(), "false", createMissingKeys = true)
    endIf
endFunction

bool function ShowMessageBoxes() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_Config_ShowMessageBoxes()) != "false"
endFunction

bool function SetShowMessageBoxes(bool value) global
    if value
        JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Config_ShowMessageBoxes(), "true", createMissingKeys = true)
    else
        JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Config_ShowMessageBoxes(), "false", createMissingKeys = true)
    endIf
endFunction
