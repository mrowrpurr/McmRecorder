scriptName McmRecorder_ModConfigurationMenu hidden

SKI_ConfigBase function GetMenu(string modName, bool interactive = false) global
    SKI_ConfigBase mcmMenu = McmRecorder.GetMcmInstance(modName)

    if ! mcmMenu
        float mcmLoadWaitTime = McmRecorder_Config.GetMcmMenuLoadWaitTime()
        float mcmLoadWaitInterval = McmRecorder_Config.GetMcmMenuLoadWaitInterval()
        float mcmLoadNotificationInterval = McmRecorder_Config.GetMcmMenuLoadNotificationInterval()

        if mcmLoadWaitTime
            McmRecorder_Logging.ConsoleOut("Waiting for MCM menu to load: '" + modName + "'")
            float startTime = Utility.GetCurrentRealTime()
            float lastNotification = startTime
            while (! mcmMenu) && (Utility.GetCurrentRealTime() - startTime) < mcmLoadWaitTime
                float now = Utility.GetCurrentRealTime()
                if (now - lastNotification) >= mcmLoadNotificationInterval
                    lastNotification = now
                    McmRecorder_Logging.ConsoleOut("Waiting for MCM menu to load: '" + modName + "'")
                endIf
                Utility.WaitMenuMode(mcmLoadWaitInterval) ; hard coded for now
                mcmMenu = McmRecorder.GetMcmInstance(modName)
            endWhile
        endIf
    endIf

    return mcmMenu
endFunction

function Refresh(SKI_ConfigBase mcmMenu, string modName, string pageName, bool force = false) global
    McmRecorder_McmFields.MarkMcmOptionsForReset()

    if force
        mcmMenu.CloseConfig()
    endIf

    mcmMenu.OpenConfig()

    mcmMenu.SetPage(pageName, mcmMenu.Pages.Find(pageName))

    if McmRecorder_McmHelper.IsMcmHelperMcm(mcmMenu)
        McmRecorder_McmFields.WaitToFindAllFieldsFromMcm(mcmMenu)
    endIf
endFunction

int function FindOption(SKI_ConfigBase mcmMenu, string modName, string pageName, string optionType, string selector, string wildcard, int index, string side) global
    ; TODO make these configs but which also allow you to override them per Action if possible!
    float searchTimeout = 30.0 ;JMap.getFlt(actionInfo, "timeout", 30.0) ; Default to wait for options to show up for a max of 30 seconds
    float searchInterval = 0.5 ;JMap.getFlt(actionInfo, "interval", 0.5) ; Default to try twice per second
    float searchPageLoadTime = 5.0 ;JMap.getFlt(actionInfo, "pageload", 5.0) ; Allow pages up to 5 seconds for an option to appear

    int foundOption
    float startTime = Utility.GetCurrentRealTime()
    while (! foundOption) && (Utility.GetCurrentRealTime() - startTime) < searchTimeout
        foundOption = AttemptFindOption(mcmMenu, modName, pageName, optionType, selector, wildcard, index, side, searchInterval, searchPageLoadTime)
        if ! foundOption ; Does this ever run?
            McmRecorder_UI.Notification(modName + ": " + pageName + " (search for " + selector + ")")
            Utility.WaitMenuMode(searchInterval)
        endIf
    endWhile
    return foundOption
endFunction

int function AttemptFindOption(SKI_ConfigBase mcmMenu, string modName, string pageName, string optionType, string selector, string wildcard, int index, string side, float searchInterval, float searchPageLoadTime) global
    float startTime = Utility.GetCurrentRealTime()
    while (Utility.GetCurrentRealTime() - startTime) < searchPageLoadTime
        int options = McmRecorder_McmFields.OptionsForModPage_ByOptionType(modName, pageName, optionType)
        int optionsCount = JArray.count(options)
        int matchCount = 0
        int i = 0
        while i < optionsCount
            int option = JArray.getObj(options, i)
            
            string optionText = JMap.getStr(option, "text")
            if side == "right"
                optionText = JMap.getStr(option, "strValue")
            endIf

            bool matches
            if wildcard
                matches = StringUtil.Find(optionText, wildcard) > -1
            else
                matches = optionText == selector
            endIf

            if matches
                matchCount += 1
                if index > -1 ; This must be the Nth one on the page
                    if index == matchCount
                        return option
                    endIf
                else
                    return option
                endIf
            endIf

            i += 1
        endWhile
        
        Utility.WaitMenuMode(searchInterval)

        Refresh(mcmMenu, modName, pageName, force = true) ; Wasn't on the page! Let's refresh the page.

        string debugPrefix = "" + modName
        if pageName
            debugPrefix += ": " + pageName
        endIf
        debugPrefix += " (" + selector + ")"
        if index > -1
            debugPrefix += " [" + index + "]"
        endIf

        if (Utility.GetCurrentRealTime() - startTime) >= 4 ; Every 4 seconds print an update
            McmRecorder_Logging.ConsoleOut(debugPrefix + " Searching for MCM option...")
            McmRecorder_UI.Notification(modName + ": " + pageName + " (search for " + selector + ")")
        endIf
    endWhile

    return 0
endFunction
