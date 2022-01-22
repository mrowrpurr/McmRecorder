scriptName McmRecorder_McmWatcher extends Quest

SKI_ConfigBase property MCM auto

McmRecorder_McmWatcher function GetInstance() global
    return Quest.GetQuest("McmRecorder") as McmRecorder_McmWatcher
endFunction

function ListenForMcmsToWatch() global
    McmRecorder_McmWatcher.GetInstance().RegisterForModEvent("McmRecorder_Private_WatchMcmFields", "OnWatchMcm")
endFunction

event OnWatchMcm()
    while MCM
        McmRecorder_Logging.ConsoleOut(mcm.OptionBuffer_TypeWithFlags)
        Utility.WaitMenuMode(3) ; make like 50ms, right now 3000ms for testing
    endWhile
endEvent

function BeginWatchingMcm(SKI_ConfigBase mcm) global
    McmRecorder_McmWatcher watcher = GetInstance()
    watcher.MCM = mcm
    int eventHandle = ModEvent.Create("McmRecorder_Private_WatchMcmFields")
    ModEvent.Send(eventHandle)
endFunction
