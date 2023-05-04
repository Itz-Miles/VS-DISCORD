package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0';

	var menuItems:FlxTypedGroup<FlxSprite>;
	var sideBarSelect = 0;
	var selectedSomethin:Bool = false;
	private var camGame:FlxCamera;
	private var menuBF:Character = null;
	var camFollow:FlxObject;

	public static var camFollowPos:FlxObject;

	var menuGF:Character;
	var sideBar:FlxSprite;
	var directoryBar:FlxSprite;
	var bg:Dynamic;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		Conductor.changeBPM(102);

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('backgrounds/menuBG', "shared"));
		bg.scrollFactor.set(0, 0.2);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		sideBar = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/sideBar', "shared"));
		sideBar.scrollFactor.set(0, 0);
		add(sideBar);

		directoryBar = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/menuBar', "shared"));
		directoryBar.scrollFactor.set(0, 0);
		add(directoryBar);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);
		menuBF = new Character(660, 150, 'menuBF', false, "shared");
		menuBF.scrollFactor.set(0, 0.2);
		add(menuBF);

		menuGF = new Character(416, 212, 'menuGF', false, "shared");
		menuGF.scrollFactor.set(0, 0.2);
		menuGF.color = 0x777989;
		add(menuGF);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...7)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 90) + (i * 4));
			menuItem.ID = i;
			menuItem.loadGraphic(Paths.image('menus/menuItems/item' + menuItem.ID + (sideBarSelect == menuItem.ID), "shared"));
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		}
		
		var directoryTitle:FlxText = new FlxText(0, 12, 0, "select a submenu", 36);
		directoryTitle.scrollFactor.set(0, 0);
		directoryTitle.setFormat(Paths.font('Minecrafter-Regular.ttf'), 36, FlxColor.BLACK);
		directoryTitle.updateHitbox();
		directoryTitle.screenCenter(X);
		//directoryTitle.x += 264 / 2;
		add(directoryTitle);

		reloadItemGraphics('precache');

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				sideBarSelect -= 1;
				reloadItemGraphics('change');
			}
			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				sideBarSelect += 1;
				reloadItemGraphics('change');
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				sideBarSelect = 69420;
				reloadItemGraphics('enter');
				MusicBeatState.switchState(new TitleState());
			}
			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				reloadItemGraphics('enter');

				switch (sideBarSelect)
				{
					case 0:
						FlxG.sound.play(Paths.sound('confirmMenu'));
						menuGF.act(['hey', 15]);
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							MusicBeatState.switchState(new StoryMenuState(), 0);
						});
					case 1:
						FlxG.sound.play(Paths.sound('confirmMenu'));
						menuGF.act(['hey', 15]);
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							MusicBeatState.switchState(new FreeplayState());
						});
					case 2:
						FlxG.sound.play(Paths.sound('confirmMenu'));
						menuGF.act(['hey', 15]);
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							MusicBeatState.switchState(new options.OptionsState());
						});
					case 3:
						selectedSomethin = false;
						FlxG.sound.play(Paths.sound('giggles'));
					case 4:
						selectedSomethin = false;
						FlxG.sound.play(Paths.sound('giggles'));
					case 5:
						FlxG.sound.play(Paths.sound('confirmMenu'));
						menuGF.act(['hey', 15]);
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							MusicBeatState.switchState(new CreditsState());
						});
					case 6:
						selectedSomethin = false;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						CoolUtil.browserLoad('https://www.newgrounds.com/portal/view/770371');
				}
			}
		}
		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
		if (!(menuGF.animation.curAnim.name == 'hey'))
			menuGF.dance();
		menuBF.dance(true);
	}

	function reloadItemGraphics(sus:String = '')
	{
		if (sideBarSelect == 7)
			sideBarSelect = 0;
		if (sideBarSelect <= -1)
			sideBarSelect = 6;
		switch (sus)
		{
			case 'precache': // used during the transition
				menuItems.forEach(function(spr:FlxSprite)
				{ // loads all of the selected graphics in advance
					spr.loadGraphic(Paths.image('menus/menuItems/item' + spr.ID + 'true', "shared"));
					reloadItemGraphics('change');
				});

			case 'change':
				menuItems.forEach(function(spr:FlxSprite)
				{ // loads the graphic based on whether it's selected
					spr.loadGraphic(Paths.image('menus/menuItems/item' + spr.ID + (sideBarSelect == spr.ID), "shared"));
				});

			case 'enter':
				menuItems.forEach(function(spr:FlxSprite)
				{ // isolates the sprite based on wether it's selected
					if (sideBarSelect != 3 && sideBarSelect != 4 && sideBarSelect != 6 && sideBarSelect != 69420)
					{
						spr.alpha = (sideBarSelect == spr.ID) ? 1.0 : 0.5;
					}
				});
		}

		menuItems.forEach(function(spr:FlxSprite)
		{ // sets camfollow's position based on whether it's selected
			if (spr.ID == sideBarSelect)
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
		});
	}
}
