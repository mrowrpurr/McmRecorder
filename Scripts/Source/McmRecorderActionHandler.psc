scriptName McmRecorderActionHandler extends SkyScriptActionHandler

event RegisterSyntax()
    AddSyntax("click")
    AddSyntax("toggle")
    AddSyntax("input")
    AddSyntax("color")
    AddSyntax("shortcut")
    AddSyntax("menu")
    AddSyntax("slider")
    AddSyntax("mod")
    AddSyntax("page")
endEvent

int function Execute(int scriptInstance, int actionInfo)

    Debug.MessageBox("This will run an MCM action, yo.")

    ; if McmRecorder_Playback.IsCanceled(playback) || McmRecorder_Action_Option.ShouldSkipOption(playback)
    ;     return
    ; endIf

    ; if JMap.hasKey(actionInfo, "click")
    ;     Click(scriptInstance, actionInfo)
    ; elseIf JMap.hasKey(actionInfo, "toggle")
    ;     Toggle(scriptInstance, actionInfo)
    ; elseIf JMap.hasKey(actionInfo, "input")
    ;     Input(scriptInstance, actionInfo)
    ; elseIf JMap.hasKey(actionInfo, "color")
    ;     Color(scriptInstance, actionInfo)
    ; elseIf JMap.hasKey(actionInfo, "shortcut")
    ;     Shortcut(scriptInstance, actionInfo)
    ; elseIf JMap.hasKey(actionInfo, "menu")
    ;     Menu(scriptInstance, actionInfo)
    ; elseIf JMap.hasKey(actionInfo, "slider")
    ;     Slider(scriptInstance, actionInfo)
    ; elseIf JMap.hasKey(actionInfo, "mod") || JMap.hasKey(actionInfo, "page")
    ;     ChangePage(scriptInstance, actionInfo)
    ; endIf
endFunction

int function GetPlayback(int scriptInstance)
    ; return _SkyScript_Script
endFunction

SKI_ConfigBase function GetMcmMenu()
endFunction

int function Click(int actionInfo)
endFunction

int function Toggle(int actionInfo)
endFunction

int function Input(int actionInfo)
endFunction

int function Color(int actionInfo)
endFunction

int function Shortcut(int actionInfo)
endFunction

int function Menu(int actionInfo)
endFunction

int function Slider(int actionInfo)
endFunction

int function ChangePage(int actionInfo)
endFunction

int function PlayRecording(int actionInfo)
endFunction
