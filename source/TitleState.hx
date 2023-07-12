package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	var logoBl:FlxSprite;
	var splashText:FlxSprite;
	var bg:FlxSprite;
	var titleGF:Character;
	var transitioning:Bool;
	var gamepad:FlxGamepad;
	var pressedEnter:Bool;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();

		logoBl = new FlxSprite(40, 40).loadGraphic(Paths.image('logos/logo', "shared"));
		logoBl.updateHitbox();
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		add(logoBl);

		splashText = new FlxSprite(0, 560).loadGraphic(Paths.image('text/splashText', "shared"));
		splashText.updateHitbox();
		splashText.antialiasing = ClientPrefs.globalAntialiasing;
		splashText.screenCenter(X);
		add(splashText);
		FlxTween.tween(splashText.scale, {x: 0.76, y: 0.76}, 0.1, {ease: FlxEase.cubeOut, type: FlxTweenType.PERSIST});

		titleGF = new Character(550, 195, "outlineGF", false, "shared");
		add(titleGF);

		FlxG.camera.flash(FlxColor.BLACK, 1.7);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (FlxG.keys.justPressed.ENTER || controls.ACCEPT)
			pressedEnter = true;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (!transitioning)
		{
			if (pressedEnter)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				splashText.y = 570;
				transitioning = true;
				
				FlxTween.tween(splashText, {x: splashText.x, y: splashText.y + 300}, 1.5, {ease: FlxEase.quintIn});
				FlxTween.tween(logoBl, {x: logoBl.x, y: logoBl.y - 300}, 1.5, {ease: FlxEase.quintIn});
				FlxTween.tween(FlxG.camera, {zoom: 22.0}, 1.5, {
					ease: FlxEase.quintIn,
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}

	function tweenBack(tween:FlxTween):Void
	{
		FlxTween.tween(splashText.scale, {x: 0.76, y: 0.76}, 0.165, {ease: FlxEase.cubeOut, type: FlxTweenType.PERSIST});
		FlxTween.tween(logoBl.scale, {x: 0.975, y: 0.975}, 0.165, {ease: FlxEase.cubeOut, type: FlxTweenType.PERSIST});
	}

	override function beatHit()
	{
		super.beatHit();
		if (splashText != null)
			FlxTween.tween(splashText.scale, {x: 0.79, y: 0.79}, 0.165, {type: FlxTweenType.PERSIST, ease: FlxEase.cubeOut, onComplete: tweenBack});
		if (splashText != null)
			splashText.y = 560; // might tween back later
		if (logoBl != null)
			FlxTween.tween(logoBl.scale, {x: 1, y: 1}, 0.165, {type: FlxTweenType.PERSIST, ease: FlxEase.cubeOut, onComplete: tweenBack});

		if (titleGF != null)
		{
			titleGF.dance();
		}
	}
}
