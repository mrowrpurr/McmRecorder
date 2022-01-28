scriptName McmRecorder_Recording hidden

int function Get(string recordingName) global
    return McmRecorder_Files.ReadRecordingFile(recordingName)
endFunction

function PlayByName(string recordingName) global
    int recording = Get(recordingName)
    if recording
        Play(recording)
    endIf
endFunction

function Play(int this, string startingStepName = "", int startingActionIndex = -1) global
    int playback = McmRecorder_Playback.Create(this, startingStepName, startingActionIndex)
    McmRecorder_Playback.Play(playback)
    McmRecorder_Playback.Dispose(playback)
endFunction

string function GetName(int this) global
    return JMap.getStr(this, "name")
endFunction

int function StepsByFilename(int this) global
    return McmRecorder_Files.ReadStepFilesToMap(GetName(this))
endFunction

string[] function GetStepNames(int this) global
    int stepInfos = StepsByFilename(this)
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

bool function HasInlineScript(int this) global
    return JMap.hasKey(this, "script")
endFunction

int function GetInlineScript(int this) global
    return JMap.getObj(this, "script")
endFunction

function RunInlineScript(int actionList) global
    McmRecorder_Action.PlayList(actionList)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO remove the recordingName parameter
function Save(int this) global
    McmRecorder_Files.SaveRecordingInfoFile(GetName(this), this)
endFunction

bool function IsAutorun(int this) global
    return JMap.getStr(this, "autorun") == "true"
endFunction

bool function IsVrGesture(int this) global
    return JMap.getStr(this, "gesture") == "true"
endFunction

bool function IsHidden(int this) global
    return JMap.getStr(this, "hidden") == "true"
endFunction

bool function SetIsVrGesture(int this, bool enabled = true) global
    if enabled
        JMap.setStr(this, "gesture", "true")
    else
        JMap.removeKey(this, "gesture")
    endIf
    Save(this)
endFunction

; TODO support replacements like $STEP_COUNT$ or something.
string function GetWelcomeMessage(int this) global
    return JMap.getStr(this, "welcome")
endFunction

string function GetCompleteMessage(int this) global
    return JMap.getStr(this, "complete")
endFunction

int function GetTotalActionCount(int this) global
    int actionCount = 0
    string recordingName = GetName(this)

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

    if McmRecorder_Recording.HasInlineScript(this)
        actionCount += JArray.count(JMap.getObj(this, "script"))
    endIf

    return actionCount
endFunction

string function GetDescriptionText(int this) global
    string recordingName = GetName(this)
    string[] stepNames = McmRecorder_Files.GetRecordingStepFilenames(recordingName)
    string recordingDescription = recordingName
    recordingDescription += "\nSteps: " + stepNames.Length
    return recordingDescription
endFunction

string function GetRandomRecordingName() global
    string[] currentTimeParts = StringUtil.Split(Utility.GetCurrentRealTime(), ".")
    return "Recording_" + currentTimeParts[0] + "_" + currentTimeParts[1]
endFunction
