package;

import flixel.effects.FlxFlicker;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import WeekData;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one, defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	private static var lastDifficultyName:String = '';

	var curDifficulty:Int = CoolUtil.difficultyIndex(CoolUtil.defaultDifficulties, ClientPrefs.optionsDifficulty);
	var bg:FlxSprite;
	var sideBar:FlxSprite;
	private static var curWeek:Int = 0;
	var storyMode:FlxSprite;
	var weekBox:FlxSprite;
	var directoryBar:FlxSprite;
	var controlScheme:Int = 0;
	var menuDifficulties:FlxTypedGroup<FlxSprite>;
	var difficultyPannelActive:Bool = false;
	var directoryTitle:FlxText;

	var xFile:Array<Float> = [319, 597, 987];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		DiscordClient.changePresence("Story Mode", null);
		#end

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('backgrounds/menuBG', "shared"));
		bg.screenCenter();
		bg.y += 50;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		weekBox = new FlxSprite(0, -485).loadGraphic(Paths.image('menus/weekBox', "shared"));

		sideBar = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/sideBar', "shared"));

		storyMode = new FlxSprite(0, 60).loadGraphic(Paths.image('menus/menuItems/item0true', "shared"));

		directoryBar = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/menuBar', "shared"));

		for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
		}

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if (lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}

		changeDifficulty();

		menuDifficulties = new FlxTypedGroup<FlxSprite>();

		add(sideBar);
		add(storyMode);
		for (i in 1...7)
			{
				var item:FlxSprite = new FlxSprite(0, 60 + (i * 90) + (i * 4));
				item.ID = i;
				item.loadGraphic(Paths.image('menus/menuItems/item${item.ID}false', "shared"));
				add(item);
				item.scrollFactor.set();
				item.antialiasing = ClientPrefs.globalAntialiasing;
				item.alpha = 0.5;
			}

		add(weekBox);
		FlxTween.tween(weekBox, {x: 0, y: -577}, 0.66, {ease: FlxEase.cubeIn});

		add(menuDifficulties);

		for (i in 0...CoolUtil.difficulties.length)
		{
			var menuDifficulty:FlxSprite = new FlxSprite(0, -485 + 514);
			menuDifficulty.ID = i;
			menuDifficulty.loadGraphic(Paths.image('menus/menuItems/difficulty-${menuDifficulty.ID}-${(menuDifficulty.ID == curDifficulty)}', "shared"));
			menuDifficulty.x = xFile[i];
			menuDifficulties.add(menuDifficulty);
			FlxTween.tween(menuDifficulty, {x: menuDifficulty.x, y: -577 + 514}, 0.66, {ease: FlxEase.cubeIn});
		}
		add(directoryBar);

		directoryTitle = new FlxText(0, 12, 0, "choose a world", 36);
		directoryTitle.scrollFactor.set(0, 0);
		directoryTitle.setFormat(Paths.font('Minecrafter-Regular.ttf'), 36, FlxColor.BLACK);
		directoryTitle.updateHitbox();
		directoryTitle.screenCenter(X);
		//directoryTitle.x += 264 /2;
		add(directoryTitle);

		changeWeek();
		reloadItemGraphics("precache", curDifficulty);
	}

	override function closeSubState()
	{
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		switch (controlScheme)
		{
			case 0:
				if (difficultyPannelActive) 
				{
					menuDifficulties.forEach(function(spr:FlxSprite)
					{
						FlxTween.tween(spr, {x: spr.x, y: -577 + 514}, 0.66, {ease: FlxEase.cubeIn});
						directoryTitle.text = "choose a world";
						directoryTitle.screenCenter(X);
					});
					FlxTween.tween(weekBox, {x: 0, y: -577}, 0.66, {ease: FlxEase.cubeIn});
					difficultyPannelActive = false;
				}

				if (controls.UI_UP_P)
				{
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (controls.UI_DOWN_P)
				{
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (controls.BACK)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					MusicBeatState.switchState(new MainMenuState());
				}
				if (controls.ACCEPT)
				{
					controlScheme = 1;
					//reloadItemGraphics();
				}

			case 1:
				if (!difficultyPannelActive) {
					menuDifficulties.forEach(function(spr:FlxSprite)
					{
						FlxTween.tween(spr, {x: spr.x, y: 514}, 0.66, {ease: FlxEase.bounceOut});
					});
					FlxTween.tween(weekBox, {x: 0, y: 0}, 0.66, {ease: FlxEase.bounceOut});
					directoryTitle.text = "select the difficulty";
					directoryTitle.screenCenter(X);
				difficultyPannelActive = true;
				}

				if (controls.UI_LEFT_P)
				{
					changeDifficulty(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
					reloadItemGraphics("change", curDifficulty);
				}
				if (controls.UI_RIGHT_P)
				{
					changeDifficulty(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
					reloadItemGraphics("change", curDifficulty);
				}
				if (controls.BACK)
				{
					controlScheme = 0;
				}
				if (controls.RESET)
				{
					persistentUpdate = false;
					openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				}
				if (controls.ACCEPT)
				{
					selectWeek();
					controlScheme = 3;
				}
		}

		super.update(elapsed);
	}

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			reloadItemGraphics("enter", curDifficulty);
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if (diffic == null)
				diffic = '';
			PlayState.storyDifficulty = curDifficulty;
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	var lastImagePath:String;

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // Fuck you HTML5

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}
			if (diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	function weekIsLocked(weekNum:Int)
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function reloadItemGraphics(type:String = "", difficulty:Dynamic)
		{
			switch (type)
			{
				case 'precache':
					menuDifficulties.forEach(function(spr:FlxSprite)
					{
						spr.loadGraphic(Paths.image('menus/menuItems/difficulty-${spr.ID}-true', "shared"));
						reloadItemGraphics('change', 1);
					});
	
				case 'change':
					menuDifficulties.forEach(function(spr:FlxSprite)
					{
						spr.loadGraphic(Paths.image('menus/menuItems/difficulty-${spr.ID}-${curDifficulty == spr.ID}', "shared"));
					});
	
				case 'enter':
					menuDifficulties.forEach(function(spr:FlxSprite)
					{
						if (spr.ID == curDifficulty){
							FlxFlicker.flicker(spr);

						}
					});
			}
		}
}