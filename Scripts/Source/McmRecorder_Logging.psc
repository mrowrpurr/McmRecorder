scriptName McmRecorder_Logging hidden

function Log(string text) global
    Debug.Trace("[MCM Recorder] " + text)
endFunction

function LogContainer(string text, int jcontainer) global
    Log(text + ":\n" + ToJson(jcontainer))
endFunction

string function ToJson(int jcontainer) global
    string filepath = McmRecorder_RecordingFiles.PathToRecordings() + "/" + ".temp" + "/temp.json"
    JValue.writeToFile(jcontainer, filepath)
    return MiscUtil.ReadFromFile(filepath)
endFunction

function ConsoleOut(string text) global
    MiscUtil.PrintConsole(text)
endFunction

function DumpAll(string filename = "Data/McmRecorder/.debug/McmRecorderDataDump.json") global
    JValue.writeToFile(JDB.solveObj(".mcmRecorder"), filename)
    ConsoleOut("[DEBUG] Written to " + filename)
endFunction
