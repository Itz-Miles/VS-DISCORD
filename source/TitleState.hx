package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	public static var initialized:Bool = false;

	var bgScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;
	var logoBl:FlxSprite;
	var splashText:FlxSprite;
	var titleChar:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var lastKeysPressed:Array<FlxKey> = [];

	var mustUpdate:Bool = false;
	
	public static var updateVersion:String = '';

	override public function create():Void
	{
		/*
		openfl.Lib.application.window.width = 300;
        openfl.Lib.application.window.height = 380;
        openfl.Lib.application.window.x = 532;
        openfl.Lib.application.window.y = 185;
		*/

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null) {
			StoryMenuChannel.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.fixedTimestep = false;
		FlxG.mouse.visible = false;

		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
	}

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BG_test'));
		bg.screenCenter();
		add(bg);
		
		titleChar = new FlxSprite(758, 219);
		titleChar.frames = Paths.getSparrowAtlas('GF_ass_ets');
		titleChar.animation.addByPrefix('titleIdle', 'gf_idle', 24);
		titleChar.setGraphicSize(Std.int(titleChar.width * 0.65));
		titleChar.antialiasing = ClientPrefs.globalAntialiasing;
		add(titleChar);

		logoBl = new FlxSprite(-590, -340).loadGraphic(Paths.image('logo'));
		logoBl.updateHitbox();
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		add(logoBl);
		FlxTween.tween(logoBl.scale, {x:0.39, y:0.39}, 0.1, {ease: FlxEase.cubeOut, type: FlxTween.PERSIST});

		splashText = new FlxSprite(-1000, 500).loadGraphic(Paths.image('splashText'));
		splashText.updateHitbox();
		splashText.antialiasing = ClientPrefs.globalAntialiasing;
		splashText.screenCenter(X);
		add(splashText);
        FlxTween.tween(splashText.scale, {x:0.23, y:0.23}, 0.1, {ease: FlxEase.cubeOut, type: FlxTween.PERSIST});
		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		bgScreen = new FlxSprite().loadGraphic(Paths.image('bgScreen'));
		credGroup.add(bgScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();


		credTextShit.visible = false;

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}
		
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (!transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer) {
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
			}
		}

		if (pressedEnter && !skippedIntro) {
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0) {
		for (i in 0...textArray.length) {
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0) {
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText() {
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function tweenBack(tween:FlxTween):Void {
		FlxTween.tween(splashText.scale, {x:0.33, y:0.33}, 0.165, {ease: FlxEase.cubeOut, type: FlxTween.PERSIST});
    	FlxTween.tween(logoBl.scale, {x:0.39, y:0.39}, 0.165, {ease: FlxEase.cubeOut, type: FlxTween.PERSIST});
	}

	private var sickBeats:Int = 0;
	public static var closedState:Bool = false;
	override function beatHit() {
		super.beatHit();
		if(splashText != null) FlxTween.tween(splashText.scale, {x:0.34, y:0.34}, 0.165, { type: FlxTween.PERSIST, ease: FlxEase.cubeOut, onComplete: tweenBack});
		if(logoBl != null) FlxTween.tween(logoBl.scale, {x:0.40, y:0.40}, 0.165, { type: FlxTween.PERSIST, ease: FlxEase.cubeOut, onComplete: tweenBack});

		if(titleChar != null) {
			titleChar.animation.play('titleIdle');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats) {
				case 1:
					FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText(['Runnning on Psych Engine'], 15);
				case 4:
					addMoreText('Shadow Mario', 15);
					addMoreText('RiverOaken', 15);
					addMoreText('bb-panzu', 15);
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['A mod to'], -60);
				case 8:
					addMoreText('this game below', -60);
					logoSpr.visible = true;
				case 9:
					deleteCoolText();
					logoSpr.visible = false;
				case 10:
					createCoolText(['something1']);
				case 12:
					addMoreText('something2');
				case 13:
					deleteCoolText();
				case 14:
					addMoreText('something3');
				case 15:
					addMoreText('something4');
				case 16:
					addMoreText('something5');
				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void {
		if (!skippedIntro)
		{
			remove(logoSpr);
			FlxG.camera.flash(FlxColor.BLACK, 2);
			remove(credGroup);
			skippedIntro = true;
			/*
			openfl.Lib.application.window.width = 1366;
            openfl.Lib.application.window.height = 768;
            openfl.Lib.application.window.x = 0;
        	openfl.Lib.application.window.y = 24;
			*/
		}
	}
}
