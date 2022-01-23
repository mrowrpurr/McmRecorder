- [ ] Keyboard Shortcuts not working on load games
- [ ] Also make sure that you can safely upgrade from 1.0.5 to 1.0.* ...

- [ ] Recording Viewer and Editor (and creator?)
- [ ] For recordings, instead of showing VERSION and AUTHOR - show # of mods and number of total settings

- [ ] Show errors when can't parse JSON file

- [ ] Show when dependencies are not installed
- [ ] PW's not working mods
- [ ] Pause while running
- [ ] Add better VR support by customizing the MCM menu when you're in VR!
- [ ] Set verbosity (whether messages show up )
- [ ] Cancel while running
- [ ] Choose whether to run a step or not!
- [ ] Choose a BATCH of steps to run!
- [ ] Look into supporting MCMs which were built using MCM Helper (reportedly these don't work)

- [x] Trigger automatically via SKSE
- [x] Autorun after RaceMenu close
- [x] Welcome Message
- [x] Complete Message
- [x] Extract all global functions to a private API (keep them there for now)
- [x] Track the Nth cuz that's cool
- [x] Trigger automatically via autorun: true
- [x] BUG When you record but there are no recordings it still says 'Choose a recording' - also DISABLE this text
- [x] Show console messages for recording actions (and play actions!)
- [x] Branch logic on VR and use PapyrusUtil for SSE <----
- [x] Keyboard shortcuts - include in the Recording.json
- [x] VR guestures - include in the Recording.json


- Track the Nth index for selectors which have duplicates on the page
- Can use SKSE mod events to run Recordings, Steps, or Actions
- Can put recording name(s) into a config file which will AUTOMATICALLY run the recordings!
- Can detect is a field is on the page easily (and get it)

TODO: MCM translation files

BUG: in VR when you click 'begin recording' if says 'Choose Recording To Play' even if there are none


MCM Helper Notes

SendSettingChangeEvent
a_vm->DispatchMethodCall(a_object, "OnSettingChange"sv, args, nullCallback);