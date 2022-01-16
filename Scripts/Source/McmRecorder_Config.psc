scriptName McmRecorder_Config hidden
{Responsible for checking MCM Recorder configuration settings
    
Settings are defined in Data\McmRecorder.json}

function ReloadConfig() global
    
endFunction

bool function IsSkyrimVR() global
    return Game.GetModByName("SkyrimVR.esm") != 255
endFunction
