scriptName McmRecorder_PlayerAlias extends ReferenceAlias

event OnPlayerLoadGame()
    (GetOwningQuest() as McmRecorder).SaveGameLoaded()
endEvent
