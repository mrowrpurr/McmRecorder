scriptName McmRecorderMCM extends SKI_ConfigBase

McmRecorder Recorder

int oid_Record
int oid_Stop

event OnConfigInit()
    ModName = "MCM Recorder"
    Recorder = (self as Quest) as McmRecorder
    Pages = new string[1]
    Pages[0] = "Settings"
endEvent

event OnPageReset(string page)
    if McmRecorder.IsRecording()
        oid_Stop = AddTextOption("Currently Recording!", "STOP RECORDING", OPTION_FLAG_NONE)
        AddTextOption(McmRecorder.GetCurrentRecordingName(), "", OPTION_FLAG_DISABLED)
    else
        oid_Record = AddInputOption("Click to begin recording:", "BEGIN RECORDING", OPTION_FLAG_NONE)
        AddTextOption("You will be prompted to provide a name for your recording", "", OPTION_FLAG_DISABLED)
    endIf

    SetCursorFillMode(TOP_TO_BOTTOM)
    AddToggleOption("Toggle Option", true, OPTION_FLAG_NONE)
    AddTextOption("Text option", "Text value", OPTION_FLAG_NONE)
    AddInputOption("Input option", "Input value", OPTION_FLAG_NONE)
    AddSliderOption("Slider option", 0.0, "{0}", OPTION_FLAG_NONE)
    AddKeyMapOption("KeyMapOption", 42, OPTION_FLAG_NONE)
    AddMenuOption("Menu Option", "Menu option value", OPTION_FLAG_NONE)
    AddColorOption("Color option", 0, OPTION_FLAG_NONE)
endEvent

event OnOptionSelect(int optionId)
    if optionId == oid_Stop
        Debug.MessageBox("STOP")
    endIf
endEvent

event OnOptionInputAccept(int optionId, string text)
    McmRecorder.BeginRecording(text)
    ForcePageReset()
    Debug.MessageBox("Recording Started\n\nYou can now interact with MCM menus and all interactions will be recorded.\n\nWhen you are finished, return to this page to stop the recording. You will be prompted to save or delete the recording.\n\nRecordings are saved in Data\\McmRecorder")
endEvent

event OnOptionInputOpen(int optionId)
    if optionId == oid_Record
        string[] currentTimeParts = StringUtil.Split(Utility.GetCurrentRealTime(), ".")
        SetInputDialogStartText("Recording_" + currentTimeParts[0] + "_" + currentTimeParts[1])
    endIf
endEvent