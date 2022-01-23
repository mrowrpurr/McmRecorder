scriptName McmRecorder_McmWatcher extends Quest

SKI_ConfigBase property McmMenu auto

McmRecorder_McmWatcher function GetInstance() global
    return Quest.GetQuest("McmRecorder") as McmRecorder_McmWatcher
endFunction

function ListenForMcmsToWatch() global
    McmRecorder_McmWatcher.GetInstance().RegisterForModEvent("McmRecorder_Private_WatchMcmFields", "OnWatchMcm")
endFunction

event OnWatchMcm()
    while McmMenu
        ; McmRecorder_Logging.ConsoleOut(mcm.OptionBuffer_Text)
        ; McmRecorder_Logging.ConsoleOut(mcm.OptionBuffer_TypeWithFlags)

        int i = 0
        while i < McmMenu.OptionBuffer_TypeWithFlags.Length
            int optionWithFlags = McmMenu.OptionBuffer_TypeWithFlags[i]
            if optionWithFlags
                int optionType = Math.LogicalAnd(optionWithFlags, 0xFF)
                int optionFlags = Math.RightShift(Math.LogicalAnd(optionWithFlags, 0xFF00), 8)
                string text = McmMenu.OptionBuffer_Text[i]
                McmRecorder_Logging.ConsoleOut(McmMenu.ModName + " " + McmMenu.CurrentPage + " " + text + " Type:" + optionType + " Flags:" + optionFlags)
            endIf
            i += 1
        endWhile

        Utility.WaitMenuMode(3) ; make like 50ms, right now 3000ms for testing
    endWhile
endEvent

function BeginWatchingMcm(SKI_ConfigBase mcmMenu) global
    McmRecorder_McmWatcher watcher = GetInstance()
    watcher.McmMenu = mcmMenu
    int eventHandle = ModEvent.Create("McmRecorder_Private_WatchMcmFields")
    ModEvent.Send(eventHandle)
endFunction
