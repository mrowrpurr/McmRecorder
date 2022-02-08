scriptName McmRecorder_MCM_Home_RecordingDetails hidden

function Render(McmRecorderMCM mcmMenu) global
    string recordingName = mcmMenu.RecordingDetails_CurrentRecordingName
    mcmMenu.SetTitleText(recordingName)
    mcmMenu.SetCursorFillMode(mcmMenu.TOP_TO_BOTTOM)
    mcmMenu.AddHeaderOption("hello there!", mcmMenu.OPTION_FLAG_NONE)
    mcmMenu.AddTextOption("Selected Recording:", "", mcmMenu.OPTION_FLAG_DISABLED)
    mcmMenu.AddTextOption("", recordingName, mcmMenu.OPTION_FLAG_DISABLED)
endFunction
