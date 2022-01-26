scriptName McmRecorder_Recording hidden

int function Get(string recordingName) global
    return McmRecorder_Files.ReadRecordingFile(recordingName)
endFunction

string function GetName(int recordingInfo) global
    return JMap.getStr(recordingInfo, "name")
endFunction

string[] function GetStepNames(int recordingInfo) global
    int stepInfos = Mcmrecorder_Files.ReadStepFilesToMap(GetName(recordingInfo))
    string[] stepNames
    if stepInfos
        stepNames = Utility.CreateStringArray(JMap.count(stepInfos))
        string[] fileNames = JMap.allKeysPArray(stepInfos)
        int i = 0
        while i < stepNames.Length
            stepNames[i] = McmRecorder_Files.FilenameWithoutExtension(fileNames[i], ".json")
            i += 1
        endWhile
    endIf
    return stepNames
endFunction

bool function HasInlineScript(int recordingInfo) global
    return JMap.hasKey(recordingInfo, "script")
endFunction

function RunInlineScript(int recordingInfo) global
    if HasInlineScript(recordingInfo)
        int actionList = JMap.getObj(recordingInfo, "script")
        McmRecorder_Action.PlayList(actionList)
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO remove the recordingName parameter
function Save(int recordingInfo) global
    McmRecorder_Files.SaveRecordingInfoFile(GetName(recordingInfo), recordingInfo)
endFunction

bool function IsAutorun(int recordingInfo) global
    return JMap.getStr(recordingInfo, "autorun") == "true"
endFunction

bool function IsVrGesture(int recordingInfo) global
    return JMap.getStr(recordingInfo, "gesture") == "true"
endFunction

bool function IsHidden(int recordingInfo) global
    return JMap.getStr(recordingInfo, "hidden") == "true"
endFunction

bool function SetIsVrGesture(int recordingInfo, bool enabled = true) global
    if enabled
        JMap.setStr(recordingInfo, "gesture", "true")
    else
        JMap.removeKey(recordingInfo, "gesture")
    endIf
    Save(recordingInfo)
endFunction

; TODO support replacements like $STEP_COUNT$ or something.
string function GetWelcomeMessage(int recordingInfo) global
    return JMap.getStr(recordingInfo, "welcome")
endFunction

string function GetCompleteMessage(int recordingInfo) global
    return JMap.getStr(recordingInfo, "complete")
endFunction

int function GetTotalActionCount(int recordingInfo) global
    int actionCount = 0
    string recordingName = GetName(recordingInfo)

    int steps = McmRecorder_Files.ReadStepFilesToMap(recordingName)
    if steps
        string[] stepNames = JMap.allKeysPArray(steps)
        int stepCount = JMap.count(steps)
        int i = 0
        while i < stepCount
            int step = JMap.getObj(steps, stepNames[i])
            actionCount += JArray.count(step) ; <--- this is how many actions there are
            i += 1
        endWhile
    endIf

    if McmRecorder_Recording.HasInlineScript(recordingInfo)
        actionCount += JArray.count(JMap.getObj(recordingInfo, "script"))
    endIf

    return actionCount
endFunction

string function GetDescriptionText(int recordingInfo) global
    string recordingName = GetName(recordingInfo)
    string[] stepNames = McmRecorder_Files.GetRecordingStepFilenames(recordingName)
    string recordingDescription = recordingName
    recordingDescription += "\nSteps: " + stepNames.Length
    return recordingDescription
endFunction

string function GetRandomRecordingName() global
    string[] currentTimeParts = StringUtil.Split(Utility.GetCurrentRealTime(), ".")
    return "Recording_" + currentTimeParts[0] + "_" + currentTimeParts[1]
endFunction
