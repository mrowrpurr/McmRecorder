scriptName McmRecorderMCM extends SKI_ConfigBase

McmRecorder Recorder

int oid_Record
int oid_Stop
int[] oids_Recordings
string[] recordings

event OnConfigInit()
    ModName = "MCM Recorder"
    Recorder = (self as Quest) as McmRecorder
endEvent

event OnPageReset(string page)
    if McmRecorder.IsRecording()
        oid_Stop = AddTextOption("Currently Recording!", "STOP RECORDING", OPTION_FLAG_NONE)
        AddTextOption(McmRecorder.GetCurrentRecordingName(), "", OPTION_FLAG_DISABLED)
    else
        oid_Record = AddInputOption("Click to begin recording:", "BEGIN RECORDING", OPTION_FLAG_NONE)
        AddTextOption("You will be prompted to provide a name for your recording", "", OPTION_FLAG_DISABLED)
    endIf
    ListRecordings()
endEvent

function ListRecordings()
    SetCursorFillMode(TOP_TO_BOTTOM)
    recordings = McmRecorder.GetRecordingNames()
    if recordings.Length
        AddEmptyOption()
        AddTextOption("Choose a recording to play:", "", OPTION_FLAG_NONE)
        oids_Recordings = Utility.CreateIntArray(recordings.Length)
        int i = 0
        while i < recordings.Length
            oids_Recordings[i] = AddTextOption("", recordings[i], OPTION_FLAG_NONE)
            i += 1
        endWhile
    endIf
endFunction

event OnOptionSelect(int optionId)
    if optionId == oid_Stop
        Debug.MessageBox("STOP")
    elseIf oids_Recordings.Find(optionId) > -1
        if ShowMessage("Are you sure you would like to play this recording?", true, "Yes", "No")
            int recordingIndex = oids_Recordings.Find(optionId)
            McmRecorder.PlayRecording(recordings[recordingIndex])
        endIf
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
