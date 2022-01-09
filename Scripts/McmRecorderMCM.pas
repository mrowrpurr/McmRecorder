.info
  .source "McmRecorderMCM.psc"
  .modifyTime 1641755191
  .compileTime 1641755286
  .user "mrowr"
  .computer "MROWR-PURR"
.endInfo
.userFlagsRef
  .flag conditional 1
  .flag hidden 0
.endUserFlagsRef
.objectTable
  .object McmRecorderMCM SKI_ConfigBase
    .userFlags 0
    .docString ""
    .autoState 
    .variableTable
      .variable Recorder McmRecorder
        .userFlags 0
        .initialValue None
      .endVariable
      .variable oid_Record int
        .userFlags 0
        .initialValue None
      .endVariable
      .variable oid_Stop int
        .userFlags 0
        .initialValue None
      .endVariable
      .variable oids_Recordings int[]
        .userFlags 0
        .initialValue None
      .endVariable
      .variable recordings string[]
        .userFlags 0
        .initialValue None
      .endVariable
      .variable isPlayingRecording bool
        .userFlags 0
        .initialValue None
      .endVariable
      .variable currentlyPlayingRecordingName string
        .userFlags 0
        .initialValue None
      .endVariable
    .endVariableTable
    .propertyTable
    .endPropertyTable
    .stateTable
      .state
        .function GetState
          .userFlags 0
          .docString "Function that returns the current state"
          .return String
          .paramTable
          .endParamTable
          .localTable
          .endLocalTable
          .code
            RETURN ::state
          .endCode
        .endFunction
        .function GotoState
          .userFlags 0
          .docString "Function that switches this object to the specified state"
          .return None
          .paramTable
            .param newState String
          .endParamTable
          .localTable
            .local ::NoneVar None
          .endLocalTable
          .code
            CALLMETHOD onEndState self ::NoneVar
            ASSIGN ::state newState
            CALLMETHOD onBeginState self ::NoneVar
          .endCode
        .endFunction
        .function OnConfigInit 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
          .endParamTable
          .localTable
            .local ::temp0 quest
            .local ::temp1 mcmrecorder
          .endLocalTable
          .code
            ASSIGN ::ModName_var "MCM Recorder" ;@line 13
            CAST ::temp0 self ;@line 14
            CAST ::temp1 ::temp0 ;@line 14
            ASSIGN Recorder ::temp1 ;@line 14
          .endCode
        .endFunction
        .function OnPageReset 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
            .param page string
          .endParamTable
          .localTable
            .local ::temp2 bool
            .local ::nonevar none
            .local ::temp3 int
            .local ::temp4 string
          .endLocalTable
          .code
            CALLSTATIC mcmrecorder IsRecording ::temp2  ;@line 18
            JUMPF ::temp2 label1 ;@line 18
            PROPGET OPTION_FLAG_NONE self ::temp3 ;@line 19
            CALLMETHOD AddTextOption self ::temp3 "Currently Recording!" "STOP RECORDING" ::temp3 ;@line 19
            ASSIGN oid_Stop ::temp3 ;@line 19
            CALLSTATIC mcmrecorder GetCurrentRecordingName ::temp4  ;@line 20
            PROPGET OPTION_FLAG_DISABLED self ::temp3 ;@line 20
            CALLMETHOD AddTextOption self ::temp3 ::temp4 "" ::temp3 ;@line 20
            JUMP label0
            label1:
            PROPGET OPTION_FLAG_NONE self ::temp3 ;@line 22
            CALLMETHOD AddInputOption self ::temp3 "Click to begin recording:" "BEGIN RECORDING" ::temp3 ;@line 22
            ASSIGN oid_Record ::temp3 ;@line 22
            PROPGET OPTION_FLAG_DISABLED self ::temp3 ;@line 23
            CALLMETHOD AddTextOption self ::temp3 "You will be prompted to provide a name for your recording" "" ::temp3 ;@line 23
            label0:
            CALLMETHOD ListRecordings self ::nonevar  ;@line 25
          .endCode
        .endFunction
        .function ListRecordings 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
          .endParamTable
          .localTable
            .local ::temp5 int
            .local ::nonevar none
            .local ::temp6 string[]
            .local ::temp7 int
            .local ::temp8 int[]
            .local ::temp9 bool
            .local i int
            .local ::temp10 string
            .local ::temp11 int
          .endLocalTable
          .code
            PROPGET TOP_TO_BOTTOM self ::temp5 ;@line 29
            CALLMETHOD SetCursorFillMode self ::nonevar ::temp5 ;@line 29
            CALLSTATIC mcmrecorder GetRecordingNames ::temp6  ;@line 30
            ASSIGN recordings ::temp6 ;@line 30
            ARRAYLENGTH ::temp5 recordings ;@line 31
            JUMPF ::temp5 label5 ;@line 31
            CALLMETHOD AddEmptyOption self ::temp7  ;@line 32
            PROPGET OPTION_FLAG_NONE self ::temp7 ;@line 33
            CALLMETHOD AddTextOption self ::temp7 "Choose a recording to play:" "" ::temp7 ;@line 33
            ARRAYLENGTH ::temp7 recordings ;@line 34
            CALLSTATIC utility CreateIntArray ::temp8 ::temp7 0 ;@line 34
            ASSIGN oids_Recordings ::temp8 ;@line 34
            ASSIGN i 0 ;@line 35
            label3:
            ARRAYLENGTH ::temp7 recordings ;@line 36
            COMPARELT ::temp9 i ::temp7 ;@line 36
            JUMPF ::temp9 label4 ;@line 36
            ARRAYGETELEMENT ::temp10 recordings i ;@line 37
            PROPGET OPTION_FLAG_NONE self ::temp11 ;@line 37
            CALLMETHOD AddTextOption self ::temp11 "" ::temp10 ::temp11 ;@line 37
            ASSIGN ::temp7 ::temp11 ;@line 37
            ARRAYSETELEMENT oids_Recordings i ::temp7 ;@line 37
            IADD ::temp7 i 1 ;@line 38
            ASSIGN i ::temp7 ;@line 38
            JUMP label3
            label4:
            JUMP label2
            label5:
            label2:
          .endCode
        .endFunction
        .function OnOptionSelect 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
            .param optionId int
          .endParamTable
          .localTable
            .local ::temp12 bool
            .local ::temp13 int
            .local ::temp14 bool
            .local ::nonevar none
            .local ::temp15 bool
            .local ::temp16 string
            .local recordingIndex int
          .endLocalTable
          .code
            COMPAREEQ ::temp12 optionId oid_Stop ;@line 44
            JUMPF ::temp12 label10 ;@line 44
            CALLSTATIC mcmrecorder StopRecording ::nonevar  ;@line 45
            CALLMETHOD ForcePageReset self ::nonevar  ;@line 46
            JUMP label6
            label10:
            ARRAYFINDELEMENT oids_Recordings ::temp13 optionId 0 ;@line 47
            COMPAREGT ::temp14 ::temp13 -1 ;@line 47
            JUMPF ::temp14 label9 ;@line 47
            CALLMETHOD ShowMessage self ::temp15 "Are you sure you would like to play this recording?" true "Yes" "No" ;@line 48
            JUMPF ::temp15 label8 ;@line 48
            ARRAYFINDELEMENT oids_Recordings ::temp13 optionId 0 ;@line 49
            ASSIGN recordingIndex ::temp13 ;@line 49
            CALLSTATIC debug MessageBox ::nonevar "Please close the MCM to begin playing this recording." ;@line 50
            ARRAYGETELEMENT ::temp16 recordings recordingIndex ;@line 51
            ASSIGN currentlyPlayingRecordingName ::temp16 ;@line 51
            CALLMETHOD RegisterForMenu self ::nonevar "Journal Menu" ;@line 52
            JUMP label7
            label8:
            label7:
            JUMP label6
            label9:
            label6:
          .endCode
        .endFunction
        .function OnOptionInputAccept 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
            .param optionId int
            .param text string
          .endParamTable
          .localTable
            .local ::nonevar none
          .endLocalTable
          .code
            CALLSTATIC mcmrecorder BeginRecording ::nonevar text ;@line 58
            CALLMETHOD ForcePageReset self ::nonevar  ;@line 59
            CALLSTATIC debug MessageBox ::nonevar "Recording Started!\n\nYou can now interact with MCM menus and all interactions will be recorded.\n\nWhen you are finished, return to this page to stop the recording (or quit the game).\n\nRecordings are saved in simple text files inside of Data\\McmRecorder\\ which you can edit to tweak your recording without completely re-recording it :)" ;@line 60
          .endCode
        .endFunction
        .function OnOptionInputOpen 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
            .param optionId int
          .endParamTable
          .localTable
            .local ::temp17 bool
            .local ::temp18 float
            .local ::temp19 string
            .local ::temp20 string[]
            .local ::temp21 string
            .local ::nonevar none
            .local currentTimeParts string[]
          .endLocalTable
          .code
            COMPAREEQ ::temp17 optionId oid_Record ;@line 64
            JUMPF ::temp17 label12 ;@line 64
            CALLSTATIC utility GetCurrentRealTime ::temp18  ;@line 65
            CAST ::temp19 ::temp18 ;@line 65
            CALLSTATIC stringutil Split ::temp20 ::temp19 "." ;@line 65
            ASSIGN currentTimeParts ::temp20 ;@line 65
            ARRAYGETELEMENT ::temp19 currentTimeParts 0 ;@line 66
            STRCAT ::temp19 "Recording_" ::temp19 ;@line 66
            STRCAT ::temp19 ::temp19 "_" ;@line 66
            ARRAYGETELEMENT ::temp21 currentTimeParts 1 ;@line 66
            STRCAT ::temp19 ::temp19 ::temp21 ;@line 66
            CALLMETHOD SetInputDialogStartText self ::nonevar ::temp19 ;@line 66
            JUMP label11
            label12:
            label11:
          .endCode
        .endFunction
        .function OnMenuOpen 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
            .param menuName string
          .endParamTable
          .localTable
            .local ::temp22 bool
            .local ::temp23 string
            .local ::nonevar none
          .endLocalTable
          .code
            COMPAREEQ ::temp22 menuName "Journal Menu" ;@line 71
            JUMPF ::temp22 label16 ;@line 71
            JUMPF isPlayingRecording label15 ;@line 72
            STRCAT ::temp23 "MCM Recorder " currentlyPlayingRecordingName ;@line 73
            STRCAT ::temp23 ::temp23 " playback in progress. Opening MCM menu not recommended!" ;@line 73
            CALLSTATIC debug MessageBox ::nonevar ::temp23 ;@line 73
            JUMP label14
            label15:
            label14:
            JUMP label13
            label16:
            label13:
          .endCode
        .endFunction
        .function OnMenuClose 
          .userFlags 0
          .docString ""
          .return NONE
          .paramTable
            .param menuName string
          .endParamTable
          .localTable
            .local ::temp24 bool
            .local ::temp25 bool
            .local ::temp26 string
            .local ::nonevar none
          .endLocalTable
          .code
            COMPAREEQ ::temp24 menuName "Journal Menu" ;@line 79
            JUMPF ::temp24 label21 ;@line 79
            CAST ::temp25 currentlyPlayingRecordingName ;@line 80
            JUMPF ::temp25 label19 ;@line 80
            NOT ::temp25 isPlayingRecording ;@line 80
            CAST ::temp25 ::temp25 ;@line 80
            label19:
            JUMPF ::temp25 label20 ;@line 80
            ASSIGN isPlayingRecording true ;@line 81
            STRCAT ::temp26 "Playing MCM recording " currentlyPlayingRecordingName ;@line 82
            CALLSTATIC debug MessageBox ::nonevar ::temp26 ;@line 82
            CALLSTATIC mcmrecorder PlayRecording ::nonevar currentlyPlayingRecordingName ;@line 83
            ASSIGN isPlayingRecording false ;@line 84
            ASSIGN currentlyPlayingRecordingName "" ;@line 85
            CALLMETHOD UnregisterForMenu self ::nonevar "Journal Menu" ;@line 86
            JUMP label18
            label20:
            label18:
            JUMP label17
            label21:
            label17:
          .endCode
        .endFunction
      .endState
    .endStateTable
  .endObject
.endObjectTable