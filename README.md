# FNF-VS-Discord
Source code for VS Discord: A mod to Friday Night Funkin'

# Installation:

If you just want to play VS Discord, just download and play here: (put updated gamebanana hyperlink thingie here)

## Visual Studio
`windows` To install the software needed to compile: install [Visual Studio 19](https://visualstudio.microsoft.com/vs/older-downloads/#visual-studio-2019-and-other-products) and ONLY these components:
```
MSVC v142 - VS 2019 C++ x64/x86 build tools
Windows SDK (10.0.17763.0)
```
`Other Platforms` Do nothing.

## Command Prompt/Terminal
`windows` any of these methods should send you to a terminal, where you can run commands needed to compile the game.
```
Ctrl + Shift + p, and set directory.

open your directory, select Project.xml, and click "file" > "Open Windows Powershell".
```

`mac` any of these methods should send you to a terminal, where you can run commands needed to compile the game.
```
Open Terminal in Launchpad's Utillities folder.

Spotlight Search for Terminal.
```

## Haxe
You must have [the most up-to-date version of Haxe](https://haxe.org/download/) (4.2.4+) in order to compile.

## HaxeFlixel
To install the latest stable version of HaxeFlixel needed to compile, run the following commands:

```
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools setup
```
You can update HaxeFlixel anytime by running this command:
```
haxelib update flixel
```
## Funkin' Addons
To install additonal libraries needed to compile, run the following commands:
```
haxelib install flixel
haxelib install flixel addons
haxelib install flixel-ui
haxelib install hscript
haxelib install newgrounds
```
## GIT-scm
To make installing packages from GitHub repositories easier, [install GIT-scm](https://git-scm.com/downloads)
 
After installing GIT-scm, run the following commands:
```
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
```
Don't use discord??? Ignore these, and delete the text on line 133 of Project.xml: `<haxelib name="discord_rpc" if="desktop"/>`
## Funkin' Lua
To instal the LuaScript API for Friday Night Funkin', run the following command:
```
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
```
...Or don't. To play without the luascript API, delete the text on line 47 of Project.xml: `<define name="LUA_ALLOWED" if="desktop" />`

If you want video support on your mod, simply do `haxelib install hxCodec` on a Command prompt/PowerShell

otherwise, you can delete the "VIDEOS_ALLOWED" Line on Project.xml       changing this

## Compilation
Run the correlating commands in the Terminal that match your build target to compile.

Note: If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling.

`windows`
```
lime test windows
lime test windows -debug
```

`linux`
```
lime test linux
lime test linux debug
```

`html5`
``` 
lime test html5
lime test html5 -debug
```

`mac`
```
lime test mac
lime test mac -debug
```
