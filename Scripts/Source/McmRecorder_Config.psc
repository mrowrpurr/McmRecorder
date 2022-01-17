scriptName McmRecorder_Config hidden
{Responsible for checking MCM Recorder configuration settings
    
Settings are defined in Data\McmRecorder.json}

function ReloadConfig() global
    ; TODO
endFunction

bool function IsSkyrimVR() global
    return Game.GetModByName("SkyrimVR.esm") != 255
endFunction

bool function ShowNotifications() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_Config_ShowNotifications()) == "true"
endFunction

bool function SetShowNotifications(bool value) global
    if value
        JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Config_ShowNotifications(), "true", createMissingKeys = true)
    else
        JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Config_ShowNotifications(), "false", createMissingKeys = true)
    endIf
endFunction

bool function ShowMessageBoxes() global
    return JDB.solveStr(McmRecorder_JDB.JdbPath_Config_ShowMessageBoxes()) == "true"
endFunction

bool function SetShowMessageBoxes(bool value) global
    if value
        JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Config_ShowMessageBoxes(), "true", createMissingKeys = true)
    else
        JDB.solveStrSetter(McmRecorder_JDB.JdbPath_Config_ShowMessageBoxes(), "false", createMissingKeys = true)
    endIf
endFunction
