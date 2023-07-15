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

class IntroState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;
	var introGF:Character;
	var pressedEnter:Bool = false;
	var gamepad:FlxGamepad;

	override public function create():Void
	{
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		gamepad = FlxG.gamepads.lastActive;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayerSettings.init();

		super.create();

		FlxG.save.bind('funkin');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}
		FlxG.fixedTimestep = false;
		FlxG.mouse.visible = false;

		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		introGF = new Character(550, 195, 'outlineGF', false, "shared");
		add(introGF);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('logos/sike engine', "shared"));
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(FlxG.width / 2));
		logoSpr.updateHitbox();
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;
		logoSpr.screenCenter(X);
		logoSpr.x -= 300;
		logoSpr.y -= 150;
		add(logoSpr);

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});
		createCoolText(['Runnning on'], -30);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		// pressedenter stuff

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

		if (pressedEnter && !ClientPrefs.firstIntro)
			endIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.x -= 300;
			money.y += (i * 60) + 100 + offset;
			if (credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if (textGroup != null && credGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.x -= 300;
			coolText.y += (textGroup.length * 60) + 100 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0;

	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (introGF != null)
		{
			introGF.dance();
		}

		if (!closedState)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 2:
					logoSpr.visible = true;
				case 3:
					logoSpr.visible = false;
					deleteCoolText();
				case 4:
					createCoolText(['Based on'], -30);
					logoSpr.loadGraphic(Paths.image('logos/titlelogo', "shared"));
					logoSpr.setGraphicSize(Std.int(FlxG.width / 3));
					logoSpr.updateHitbox();
					logoSpr.screenCenter(X);
					logoSpr.x -= 300;
					logoSpr.y += 50;
				case 6:
					logoSpr.visible = true;
				case 7:
					deleteCoolText();
					logoSpr.visible = false;
				case 8:
					createCoolText(['xb9fox'], -30);
				case 9:
					addMoreText('microwave', 15);
				case 10:
					addMoreText('Present', 45);
				case 11:

				case 12:
					deleteCoolText();
				case 13:
					createCoolText(['Versus'], 0);
				case 14:
					addMoreText('Discord', 30);
				case 15:
					endIntro();
			}
		}
	}

	function endIntro()
	{
		ClientPrefs.firstIntro = false;
		FlxG.save.data.firstIntro = false;
		MusicBeatState.switchState(new TitleState(), 0.1);
		
		closedState = true;
	}
}
