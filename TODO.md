# 1.1

- [x] Remove all of the old Action files (lots)
- [ ] MCM Helper - reach out for support assistance
- [ ] Support mods with ':' in the page name
- [ ] Consistency between using name in .json and the .json filename!!!! e.g. with the confirmation box
- [ ] New MCM where you can look at an MCM Recording's steps and DELETE a step or DELETE a WHOLE recording
- [ ] Change "script" to "before" "after" and "script" where "script" replaces everything.
- [ ] Keep "welcome" and "complete" and make sure both work!
- [ ] Add a "showNotifications" variable to control top left
- [ ] Default "showNotifications" to true if TopLevel unless .json has "notifications": false <--
- [ ] Configure colors using '#aabbcc' (both recorder and playback)
- [ ] Update recorder to no longer store "mod" and "page" - separate page change actions

Make sure this shit still works, yo:
- [ ] Pause and Resume

# Future

- [ ] 128+ MCMs
- [ ] Show/Hide MCMs
- [ ] Translations





















--------------------------------------------------------------------------

- [ ] Fix playing individual Step!
- [ ] Confirm Pause and Resume and Cancel all still work!
- [ ] Represent color as string "#ffaabb" (with or without #, detect if string vs int)
- [ ] Wildcard matching for modName
- [ ] Wildcard matching for pageName

- [ ] Provide more guidance for SSE JContainers when not found when using 1.5 vs 1.6 vs VR

- [x] Inline macro in definition file `"script": []` (treated as its own step, the first step, for statistics etc)
- [ ] `"done": true` or end or exit
- [x] `"msgbox": "Some dialog message"`
- [ ] `"print": "Some console message"`
- [ ] `"notify": "Some notification message"`
- [ ] `"wait": 1.5
- [ ] `"dialog": ["Option1", "Option2"], "text": "..."`
- [ ] `"chooser": ["Option1", "Option2"]`
- [ ] Translation support for all of the above
- [ ] `"var": "coolvar", "value": 12.34`
- [ ] `"var": "mcm", "value": { "name": "Mod Name", "page": "Page Name" }` and reference "mcm.name" and "mcm.page" elsewhere
- [ ] `"msgbox": "Some dialog message", "if": "somevar"`
- [ ] `"msgbox": "Some dialog message", "if": "somevar = some value"`
- [ ] Inventory Selector
- [ ] Spell Selector
- [ ] Search results
- [ ] `"play": "recording name"`
- [ ] `"play": "recording name", "step": "step name"`
- [ ] `"console": "tgm"`
- [ ] `"pause": true`
- [ ] `"add": ["f"], "count": 1`
- [ ] `"add": ["d65", "somerandom.esp"], "count": 1`
- [ ] `"equip": ["d65", "somerandom.esp"], "count": 1`
- [ ] `"fadeToBlack": true`
- [ ] `"fadeToBlack": false`
- [ ] `"camera": "3rd"`
- [ ] `"save": true`
- [ ] `"autosave": true`
- [ ] `"background": true`
- [ ] `"coc": "whiterunorigin"`
- [ ] `"waitForEvent": "ModEventName", "paramTypes: ["int", "string", "bool"]"` (we can support a _few_ of the most common param types)
- [ ] `"modEvent": "ModEventName", "params": [1, "hi", true], "paramTypes": ["int", "string", "bool"]`
- [ ] `"quest": "QuestName": "start": true`
- [ ] `"quest": "QuestName": "stop": true`
- [ ] `"action": "MyAction", "whatever": true - ` _extensible via a FOLDER of .ini for action types_
- [ ] `"ini": "sSomething=Whatever"`

------------------------------------------------------------------------------

## Needs

- [ ] Update recorder to use "mod"/"page" once then not in the other steps
- [ ] Update SKSE Mod Events to support running recording's certain step and action
- [ ] "Async" actions
- [x] Can hide a recording in the main overview list
- [ ] Ability to Cancel Running Recording
- [ ] Update the MCM when you click Play Recording for VR folks (fix VR in general!)
- [x] Print to ~ console when recording / steps run

## Wants

- [ ] Ability to Pause Recording
- [ ] Start a recording from a particular step (required for pause)
- [ ] Can do confirmation for whether to run a certain step or action
- [ ] Can give a set of options and each option is associated with a recording or individual step
- [ ] Can have a general GOTO which will hop on over to a recordin/step

## Nice to have

- [ ] Can view steps in the MCM
- [ ] Can play individual steps in the MCM or start recording at a step

## Would be super cool

- [ ] Create recordings in the MCM!

---

- Add MORE output to the Skyrim ~ console for EVERY recording when it starts playing. And which step.

- [x] Keyboard Shortcuts not working on load games
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