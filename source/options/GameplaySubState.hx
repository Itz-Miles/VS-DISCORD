package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import CoolUtil;

using StringTools;

class GameplaySubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay';
		rpcTitle = 'Gameplay'; // for Discord Rich Presence

		var option:Option = new Option('Controller Mode', 'If checked, you can play with a controller instead of a keyboard.', 'controllerMode', 'bool',
			false);
		addOption(option);

		var option:Option = new Option('Disable Reset Button', "If checked, pressing Reset won't do anything.", 'noReset', 'bool', false);
		addOption(option);

		var option:Option = new Option('Relative Judgement', "relative", 'relativeHitCalc', 'bool', true);
		addOption(option);

		var option:Option = new Option('Hitsound Volume:', 'Hitting a note plays a "Tick" sound.', 'hitsoundVolume', 'percent', 0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset:', 'Changes how late/early you have to hit a note. Higher values mean you have to hit later.',
			'ratingOffset', 'int', 0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Hit Window:', 'The window you have in milliseconds for htting a note.', 'hitWindow', 'float', 167);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 16.6;
		option.maxValue = 166.7;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Difficulty:', "The game's default difficulty.", 'optionsDifficulty', 'string', 'Hard', CoolUtil.difficulties);
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}
