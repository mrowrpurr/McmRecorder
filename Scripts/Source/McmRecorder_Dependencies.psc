scriptName McmRecorder_Dependencies hidden

bool function IsJContainersInstalled() global
    return JContainers.APIVersion()
endFunction

bool function IsPapyrusUtilInstalled() global
    return PapyrusUtil.GetVersion() 
endFunction
