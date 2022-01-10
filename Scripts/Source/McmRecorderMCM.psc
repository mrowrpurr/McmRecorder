scriptName McmRecorderMCM extends SKI_ConfigBase

McmRecorder Recorder

int oid_Record
int oid_Stop
int[] oids_Recordings
string[] recordings
bool isPlayingRecording
string currentlyPlayingRecordingName

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
        McmRecorder.StopRecording()
        ForcePageReset()
    elseIf oids_Recordings.Find(optionId) > -1
        if ShowMessage("Are you sure you would like to play this recording?", true, "Yes", "No")
            int recordingIndex = oids_Recordings.Find(optionId)
            Debug.MessageBox("Please close the MCM to begin playing this recording.")
            currentlyPlayingRecordingName = recordings[recordingIndex]
            RegisterForMenu("Journal Menu")
        endIf
    endIf
endEvent

event OnOptionInputAccept(int optionId, string text)
    McmRecorder.BeginRecording(text)
    ForcePageReset()
    Debug.MessageBox("Recording Started!\n\nYou can now interact with MCM menus and all interactions will be recorded.\n\nWhen you are finished, return to this page to stop the recording (or quit the game).\n\nRecordings are saved in simple text files inside of Data\\McmRecorder\\ which you can edit to tweak your recording without completely re-recording it :)")
endEvent

event OnOptionInputOpen(int optionId)
    if optionId == oid_Record
        string[] currentTimeParts = StringUtil.Split(Utility.GetCurrentRealTime(), ".")
        SetInputDialogStartText("Recording_" + currentTimeParts[0] + "_" + currentTimeParts[1])
    endIf
endEvent

event OnMenuOpen(string menuName)
    if menuName == "Journal Menu"
        if isPlayingRecording
            Debug.MessageBox("MCM Recorder " + currentlyPlayingRecordingName + " playback in progress. Opening MCM menu not recommended!")            
        endIf
    endIf
endEvent

event OnMenuClose(string menuName)
    if menuName == "Journal Menu"
        if currentlyPlayingRecordingName && ! isPlayingRecording
            isPlayingRecording = true
            Debug.MessageBox("!!! Playing MCM recording " + currentlyPlayingRecordingName)
            McmRecorder.PlayRecording(currentlyPlayingRecordingName)
            isPlayingRecording = false
            currentlyPlayingRecordingName = ""
            UnregisterForMenu("Journal Menu")
        endIf
    endIf
endEvent
