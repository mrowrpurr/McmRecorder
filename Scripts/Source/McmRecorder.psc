scriptName McmRecorder extends Quest  

int property CurrentRecordingId auto

bool property IsRecording
    bool function get()
        return CurrentRecordingId
    endFunction
endProperty
