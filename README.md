<!--view the pretty format on the webpage:
https://github.com/Itz-Miles/VS-DISCORD
-->

![logo](https://user-images.githubusercontent.com/95124554/225757488-505bd0b0-8d16-4f27-a7bd-f28fbdeb0c81.png)
replace this with some cool art banner logo cover

__________________________________________________________________________________________________________________________________________
# Source code for VS Discord: A mod to Friday Night Funkin'
If you just want to play VS DISCORD, play it [here.](https://itz-miles.github.io/VS-DISCORD-test)

# Building From Source

## Haxe
You must have [the most up-to-date version of Haxe](https://haxe.org/download/) (4.2.4+) in order to compile.

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
## Haxe Module Manager
To install HMM for installing and managing libraries needed for VS DISCORD, run the following command:
`haxelib install hmm`

To install the libraries listed in hmm.json, run the following command:
`haxelib run hmm install`

## Compilation
Run the correlating commands in the terminal that match your build target to compile.

Note: If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling.

`windows`
```
lime test windows
lime test windows -debug
lime build windows
```

`linux`
```
lime test linux
lime test linux debug
lime build linux
```

`html5`
``` 
lime test html5
lime test html5 -debug
lime build html5
```

`mac`
```
lime test mac
lime test mac -debug
lime build mac
```

# Credits:

©xb9fox 2023 - Some rights reserved.

©It'z_Miles 2023 - Some rights reserved.

(will have to determine what assets to attribute for copyright purposes. Gonna use both Apache 2.0 and CC BY-NC 2.0)
(will add library and engine licencing soon)

VS DISCORD is not an official Discord product. Not licensed by or assosiated with Discord.

## VS Discord Team
* xb9fox - did a thing
* person - did a thing
* person - did a thing
* person - did a thing
* person - did a thing
* person - did a thing
* person - did a thing
* person - did a thing
* person - did a thing

* It'z_Miles - Parallax 3D

## Psych Engine:
* Shadow Mario - Programmer/Owner of Psych
* bbpanzu - Assistant Programmer
* shubs - New Input System
* PolybiusProxy - HxCodec Video Support
* Keoiki - Note Splash Animations

## Funkin' Crew
* ninjamuffin99 - Programmer of Friday Night Funkin'
* PhantomArcade -	Animator of Friday Night Funkin'
* evilsk8r - Artist of Friday Night Funkin'
* kawaisprite - Composer of Friday Night Funkin'
