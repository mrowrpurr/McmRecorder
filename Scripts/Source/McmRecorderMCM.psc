scriptName McmRecorderMCM extends SKI_ConfigBase

McmRecorder Recorder

;
; Main Page - Recording List and Recording / Stop Buttons
;
string property CurrentlyViewingRecordingName auto
int property oid_Home_Record auto
int property oid_Home_Stop auto
int[] property RecordingList_RecordingTextOptions auto
int[] property RecordingList_RecordingDetailsOptions auto
string[] property RecordingList_RecordingNames auto
; ... Main Page - But when the recording is currently paused...
int property oid_PausedRecording_Resume auto ; <--- rename and clean these up
int property oid_PausedRecording_Cancel auto


;
; Keyboard Shortcuts
;
int property oid_KeyboardShortcuts_SelectRecordingMenu auto
string[] property KeyboardShortcuts_RecordingNamesMenu auto

;
; VR Gestures
;
int[] property oid_VrGestures_RecordingToggles auto
string[] property VrGestures_RecordingNames auto

event OnConfigInit()
    ModName = "MCM Recorder"
    Recorder = (self as Quest) as McmRecorder
endEvent

event OnConfigOpen()
    if McmRecorder_VR.IsSkyrimVR() && McmRecorder_VR.IsVrikInstalled()
        Pages = new string[3]
        Pages[0] = "MCM Recordings"
        Pages[1] = "Keyboard Shortcuts"
        Pages[2] = "VR Gestures"
    else
        Pages = new string[2]
        Pages[0] = "MCM Recordings"
        Pages[1] = "Keyboard Shortcuts"
    endIf
endEvent

event OnPageReset(string page)
    if (! McmRecorder_Dependencies.IsPapyrusUtilInstalled()) || (! McmRecorder_Dependencies.IsJContainersInstalled())
        ShowDependencyError()
        return
    endIf

    if page == McmRecorder_MCM_KeyboardShortcuts.PageName()
        McmRecorder_MCM_KeyboardShortcuts.Render(self)
    elseIf page == McmRecorder_MCM_VrGestures.PageName()
        McmRecorder_MCM_VrGestures.Render(self)
    else
        McmRecorder_MCM_Home.Render(self)
    endIf
endEvent

function ShowDependencyError()
    if ! McmRecorder_Dependencies.IsPapyrusUtilInstalled()
        AddTextOption("<font color=\"#ff0000\">PapyrusUtil not found</font>", "<font color=\"#ff0000\">FAILED</font>", OPTION_FLAG_DISABLED)
        AddTextOption("<font color=\"#ff0000\">(or incompatible version installed)</font>", "", OPTION_FLAG_DISABLED)
    endIf
    if ! McmRecorder_Dependencies.IsJContainersInstalled()
        AddTextOption("<font color=\"#ff0000\">JContainers not found</font>", "<font color=\"#ff0000\">FAILED</font>", OPTION_FLAG_DISABLED)
        AddTextOption("<font color=\"#ff0000\">(or incompatible version installed)</font>", "", OPTION_FLAG_DISABLED)
    endIf
endFunction

event OnOptionSelect(int optionId)
    if CurrentPage == McmRecorder_MCM_KeyboardShortcuts.PageName()
        McmRecorder_MCM_KeyboardShortcuts.OnOptionSelect(self, optionId)
    elseIf CurrentPage == McmRecorder_MCM_VrGestures.PageName()
        McmRecorder_MCM_VrGestures.OnOptionSelect(self, optionId)
    else
        if McmRecorder_TopLevelPlayer.IsPaused()
            McmRecorder_MCM_Home_RecordingPaused.OnOptionSelect(self, optionId)
        else
            McmRecorder_MCM_Home_RecordingList.OnOptionSelect(self, optionId)
        endIf
    endIf
endEvent

event OnOptionKeyMapChange(int optionId, int keyCode, string conflictControl, string conflictName)
    McmRecorder_MCM_KeyboardShortcuts.OnOptionKeyMapChange(self, optionId, keyCode)    
endEvent

event OnOptionInputAccept(int optionId, string text)
    McmRecorder_MCM_Home_RecordingList.OnOptionInputAccept(self, optionId, text)
endEvent

event OnOptionInputOpen(int optionId)
    McmRecorder_MCM_Home_RecordingList.OnOptionInputOpen(self, optionId)
endEvent

event OnOptionMenuOpen(int optionId)
    McmRecorder_MCM_KeyboardShortcuts.OnOptionMenuOpen(self, optionId)
endEvent

event OnOptionMenuAccept(int optionId, int index)
    McmRecorder_MCM_KeyboardShortcuts.OnOptionMenuAccept(self, optionId, index)
endEvent

; Private fields from previous versions:
;
;   int oid_Record
;   int oid_Stop
;   int[] oids_Recordings
;   int oid_KeyboardShortcuts_RecordingSelectionMenu
;   int oid_ResumePausedRecording
;   int oid_CancelPausedRecording
;   string[] menuOptions
;   string[] recordings
;   bool isPlayingRecording
;   string currentlyPlayingRecordingName
;   bool openRunOrPreviewStepsPrompt