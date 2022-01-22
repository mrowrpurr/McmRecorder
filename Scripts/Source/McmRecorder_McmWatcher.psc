scriptName McmRecorder_McmWatcher extends Quest

SKI_ConfigBase property MCM auto

McmRecorder_McmWatcher function GetInstance() global
    return Quest.GetQuest("McmRecorder") as McmRecorder_McmWatcher
endFunction

function BeginWatchingMcm(SKI_ConfigBase mcm) global
    McmRecorder_McmWatcher watcher = GetInstance()
    watcher.MCM = mcm
endFunction

; function
