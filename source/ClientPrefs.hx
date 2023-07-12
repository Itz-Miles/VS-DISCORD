package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import Controls;

class ClientPrefs
{
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var hudZooms:Bool = true;
	public static var noteOffset:Int = 0;
	public static var timeBarType:String = 'Time Left';
	public static var noReset:Bool = false;
	public static var hudAlpha:Float = 1;
	public static var controllerMode:Bool = false;
	public static var optionsDifficulty:String;
	
	public static var firstIntro:Bool = true;
	public static var hitsoundVolume:Float = 0;
	public static var checkForUpdates:Bool = true;
	public static var relativeHitCalc:Bool = true;

	public static var ratingOffset:Int = 0;
	public static var hitWindow:Float = 166.7;

	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [D, LEFT],
		'note_down' => [F, DOWN],
		'note_up' => [J, UP],
		'note_right' => [K, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [ENTER, NONE],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN, NONE],
		'debug_2' => [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
		// trace(defaultKeys);
	}

	// i suck at naming things sorry
	private static var importantMap:Map<String, Array<String>> = [
		"saveBlackList" => ["keyBinds", "defaultKeys"],
		"flixelSound" => ["volume", "sound"],
		"loadBlackList" => ["keyBinds", "defaultKeys"],
	];

	public static function saveSettings()
	{
		// i dont really know if i should use set field or set property
		for (field in Type.getClassFields(ClientPrefs))
		{
			if (Type.typeof(Reflect.field(ClientPrefs, field)) != TFunction)
			{
				if (!importantMap.get("saveBlackList").contains(field))
					Reflect.setField(FlxG.save.data, field, Reflect.field(ClientPrefs, field));
			}
		}

		for (flixelS in importantMap.get("flixelSound"))
		{
			Reflect.setField(FlxG.save.data, flixelS, Reflect.field(FlxG.sound, flixelS));
		}

		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2'); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs()
	{
		for (field in Type.getClassFields(ClientPrefs))
		{
			if (Type.typeof(Reflect.field(ClientPrefs, field)) != TFunction)
			{
				if (!importantMap.get("loadBlackList").contains(field))
				{
					var defaultValue:Dynamic = Reflect.field(ClientPrefs, field);
					var flxProp:Dynamic = Reflect.field(FlxG.save.data, field);
					Reflect.setField(ClientPrefs, field, (flxProp != null ? flxProp : defaultValue));

					if (field == "showFPS" && Main.fpsVar != null)
						Main.fpsVar.visible = showFPS;

					if (field == "framerate")
					{
						if (framerate > FlxG.drawFramerate)
						{
							FlxG.updateFramerate = framerate;
							FlxG.drawFramerate = framerate;
						}
						else
						{
							FlxG.drawFramerate = framerate;
							FlxG.updateFramerate = framerate;
						}
					}
				}
			}
		}

		for (flixelS in importantMap.get("flixelSound"))
		{
			var flxProp:Dynamic = Reflect.field(FlxG.save.data, flixelS);
			if (flxProp != null)
				Reflect.setField(FlxG.sound, flixelS, flxProp);
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2');
		if (save != null && save.data.customControls != null)
		{
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls)
			{
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	public static function reloadControls()
	{
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		IntroState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		IntroState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		IntroState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = IntroState.muteKeys;
		FlxG.sound.volumeDownKeys = IntroState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = IntroState.volumeUpKeys;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
