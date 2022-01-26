scriptName McmRecorder_McmManager hidden

; Clean up and remove coupled to Action bits!

; SKI_ConfigBase function GetMcmMenu(string modName, int actionInfo, string stepName, bool promptOnFailures = true, float mcmLoadWaitTime = 10.0) global
;     SKI_ConfigBase mcmMenu = McmRecorder.GetMcmInstance(modName)

;     if (! mcmMenu) && mcmLoadWaitTime
;         McmRecorder_Logging.ConsoleOut("[Play Action] MCM not loaded: " + modName + " (waiting...)")
;         float startTime = Utility.GetCurrentRealTime()
;         float lastNotification = startTime
;         while (! mcmMenu) && (Utility.GetCurrentRealTime() - startTime) < mcmLoadWaitTime
;             float now = Utility.GetCurrentRealTime()
;             if (now - lastNotification) >= 5.0 ; Make configurable, 5 secs waiting for MCM to load
;                 lastNotification = now
;                 McmRecorder_UI.Notification("Waiting for " + modName + " MCM to load")
;                 McmRecorder_Logging.ConsoleOut("[Play Action] MCM not loaded: " + modName + " (waiting...)")
;             endIf
;             Utility.WaitMenuMode(1.0) ; hard coded for now
;             mcmMenu = McmRecorder.GetMcmInstance(modName)
;         endWhile

;         if ! mcmMenu
;             if promptOnFailures
;                 string result = McmRecorder_UI.GetUserResponseForNotFoundMod(modName)
;                 if result == "Try again"
;                     PlayAction(actionInfo, stepName, promptOnFailures, mcmLoadWaitTime)
;                 elseIf result == "Skip this mod"
;                     SetCurrentlySkippingModName(modName)
;                     return None
;                 endIf
;             else
;                 SetCurrentlySkippingModName(modName)
;                 return None
;             endIf
;             return None
;         endIf
;     endIf

;     return mcmMenu
; endFunction