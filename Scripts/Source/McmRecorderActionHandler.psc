scriptName McmRecorderActionHandler extends SkyScriptActionHandler

event RegisterActions()
    RegisterAction("mcm.click")
    RegisterAction("mcm.toggle")
    RegisterAction("mcm.input")
    RegisterAction("mcm.color")
    RegisterAction("mcm.shortcut")
    RegisterAction("mcm.menu")
    RegisterAction("mcm.slider")
    RegisterAction("mcm.play")
endEvent

bool function MatchAction(int scriptInstance, int actionInfo)
    return JMap.hasKey(actionInfo, "click")    || \
           JMap.hasKey(actionInfo, "toggle")   || \
           JMap.hasKey(actionInfo, "input")    || \
           JMap.hasKey(actionInfo, "color")    || \
           JMap.hasKey(actionInfo, "shortcut") || \
           JMap.hasKey(actionInfo, "menu")     || \
           JMap.hasKey(actionInfo, "slider")   || \
           JMap.hasKey(actionInfo, "play")
endFunction

int function Execute(int scriptInstance, string actionName, int actionInfo)
    ; TODO !
endFunction
