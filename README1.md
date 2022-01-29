# MCM Recorder

**MCM Recorder** is a Skyrim utility for recording and playback of _"**Macros**"_.

> _"Macros"_ in MCM Recorder are known as _"Recordings"_.

It is written for:
- _Individual game players_
- _Wabbajack modlist authors_
- _Twitch Skyrim permadeath players_


### Background

Originally, the project was just for recording changes made to SkyUI Mod Configuration Menus and reloading those changes in new games.

Today, the project provides an easy to learn macro scripting language for performing various actions in the game.

## Getting Started

If you looking to get started with MCM Recorder, please see its NexusMods page:

- https://www.nexusmods.com/skyrimspecialedition/mods/61719

> This page documents the _macro scripting language_ and is targeted at modlist authors.

## JSON Files

MCM Recorder uses [.json files](https://en.wikipedia.org/wiki/JSON) for to store its recordings.

JSON files are simple plain-text files. They can be edited using Notepad or any other plain text editor, such as [Notepad++](https://notepad-plus-plus.org/), [VS Code](https://code.visualstudio.com/), [Sublime Edit](https://www.sublimetext.com/), [Atom](https://atom.io/), etc.

Using Notepad is fine. The benefits of using these programs include:

- Syntax highlighting which shows the syntax in different colors, making it easier to read and write
- JSON syntax validation which will tell you when you make errors and your JSON is invalid!

> _You should **not** edit .json files using a Word Processor such as Microsoft Word_

## Recordings

Recordings can be generated via MCM Recorder or written by hand.

_This page is focused on writing MCM Recordings by hand!_

MCM Recordings are stored in:

- `Data\McmRecorder\`

### Definition Files

Scripts are defined using a definition file, e.g. `Data\McmRecorder\MyRecording.json`

```json
{
    "name": "My Cool Recording"
}
```

> Note: the `"name"` found here _and **not** the filename_ is used to define the recording name.

## More docs...

---

## LICENSE

> **Note:** the `SKI_ConfigBase` and `SKI_ConfigManager` scripts from [SkyUI](https://github.com/schlangster/skyui) are not owned by me.  
> They are owned by [schlangster](https://github.com/schlangster).
>
> All _other_ code in this project is released under the MIT license.

---