.info
  .source "McmRecorderMCM.psc"
  .modifyTime 1641608540
  .compileTime 1641608613
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
            .local ::temp2 string[]
            .local ::temp3 string
          .endLocalTable
          .code
            ASSIGN ::ModName_var "MCM Recorder" ;@line 9
            CAST ::temp0 self ;@line 10
            CAST ::temp1 ::temp0 ;@line 10
            ASSIGN Recorder ::temp1 ;@line 10
            ARRAYCREATE ::temp2 1 ;@line 11
            ASSIGN ::Pages_var ::temp2 ;@line 11
            ASSIGN ::temp3 "Settings" ;@line 12
            ARRAYSETELEMENT ::Pages_var 0 ::temp3 ;@line 12
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
            .local ::temp4 bool
            .local ::nonevar none
            .local ::temp5 int
            .local ::temp6 string
          .endLocalTable
          .code
            CALLSTATIC mcmrecorder IsRecording ::temp4  ;@line 16
            JUMPF ::temp4 label1 ;@line 16
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 17
            CALLMETHOD AddTextOption self ::temp5 "Currently Recording!" "STOP RECORDING" ::temp5 ;@line 17
            ASSIGN oid_Stop ::temp5 ;@line 17
            CALLSTATIC mcmrecorder GetCurrentRecordingName ::temp6  ;@line 18
            PROPGET OPTION_FLAG_DISABLED self ::temp5 ;@line 18
            CALLMETHOD AddTextOption self ::temp5 ::temp6 "" ::temp5 ;@line 18
            JUMP label0
            label1:
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 20
            CALLMETHOD AddInputOption self ::temp5 "Click to begin recording:" "BEGIN RECORDING" ::temp5 ;@line 20
            ASSIGN oid_Record ::temp5 ;@line 20
            PROPGET OPTION_FLAG_DISABLED self ::temp5 ;@line 21
            CALLMETHOD AddTextOption self ::temp5 "You will be prompted to provide a name for your recording" "" ::temp5 ;@line 21
            label0:
            PROPGET TOP_TO_BOTTOM self ::temp5 ;@line 24
            CALLMETHOD SetCursorFillMode self ::nonevar ::temp5 ;@line 24
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 25
            CALLMETHOD AddToggleOption self ::temp5 "Toggle Option" true ::temp5 ;@line 25
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 26
            CALLMETHOD AddTextOption self ::temp5 "Text option" "Text value" ::temp5 ;@line 26
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 27
            CALLMETHOD AddInputOption self ::temp5 "Input option" "Input value" ::temp5 ;@line 27
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 28
            CALLMETHOD AddSliderOption self ::temp5 "Slider option" 0.0 "{0}" ::temp5 ;@line 28
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 29
            CALLMETHOD AddKeyMapOption self ::temp5 "KeyMapOption" 42 ::temp5 ;@line 29
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 30
            CALLMETHOD AddMenuOption self ::temp5 "Menu Option" "Menu option value" ::temp5 ;@line 30
            PROPGET OPTION_FLAG_NONE self ::temp5 ;@line 31
            CALLMETHOD AddColorOption self ::temp5 "Color option" 0 ::temp5 ;@line 31
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
            .local ::temp7 bool
            .local ::nonevar none
          .endLocalTable
          .code
            COMPAREEQ ::temp7 optionId oid_Stop ;@line 35
            JUMPF ::temp7 label3 ;@line 35
            CALLSTATIC debug MessageBox ::nonevar "STOP" ;@line 36
            JUMP label2
            label3:
            label2:
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
            CALLSTATIC mcmrecorder BeginRecording ::nonevar text ;@line 41
            CALLMETHOD ForcePageReset self ::nonevar  ;@line 42
            CALLSTATIC debug MessageBox ::nonevar "Recording Started\n\nYou can now interact with MCM menus and all interactions will be recorded.\n\nWhen you are finished, return to this page to stop the recording. You will be prompted to save or delete the recording.\n\nRecordings are saved in Data\\McmRecorder" ;@line 43
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
            .local ::temp8 bool
            .local ::temp9 float
            .local ::temp10 string
            .local ::temp11 string[]
            .local ::temp12 string
            .local ::nonevar none
            .local currentTimeParts string[]
          .endLocalTable
          .code
            COMPAREEQ ::temp8 optionId oid_Record ;@line 47
            JUMPF ::temp8 label5 ;@line 47
            CALLSTATIC utility GetCurrentRealTime ::temp9  ;@line 48
            CAST ::temp10 ::temp9 ;@line 48
            CALLSTATIC stringutil Split ::temp11 ::temp10 "." ;@line 48
            ASSIGN currentTimeParts ::temp11 ;@line 48
            ARRAYGETELEMENT ::temp10 currentTimeParts 0 ;@line 49
            STRCAT ::temp10 "Recording_" ::temp10 ;@line 49
            STRCAT ::temp10 ::temp10 "_" ;@line 49
            ARRAYGETELEMENT ::temp12 currentTimeParts 1 ;@line 49
            STRCAT ::temp10 ::temp10 ::temp12 ;@line 49
            CALLMETHOD SetInputDialogStartText self ::nonevar ::temp10 ;@line 49
            JUMP label4
            label5:
            label4:
          .endCode
        .endFunction
      .endState
    .endStateTable
  .endObject
.endObjectTable